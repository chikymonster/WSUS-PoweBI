-- =============================================
-- WSUS REPORTING VIEWS - FINAL CORRECTED VERSION
-- Based on your actual database schema
-- =============================================

USE SUSDB
GO

PRINT '=========================================='
PRINT 'Installing WSUS Reporting Views'
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '=========================================='
PRINT ''

-- =============================================
-- VIEW 1: Overall Compliance (already works!)
-- =============================================
PRINT 'Installing View 1 of 6: vw_OverallCompliance...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_OverallCompliance')
    DROP VIEW vw_OverallCompliance
GO

CREATE VIEW vw_OverallCompliance
AS
SELECT 
    COUNT(DISTINCT ct.TargetID) AS TotalComputers,
    COUNT(DISTINCT CASE WHEN ct.LastSyncTime >= DATEADD(day, -30, GETDATE()) THEN ct.TargetID END) AS ReportingLast30Days,
    COUNT(DISTINCT CASE WHEN ct.LastSyncTime < DATEADD(day, -30, GETDATE()) OR ct.LastSyncTime IS NULL THEN ct.TargetID END) AS NotReportingLast30Days,
    COUNT(DISTINCT CASE WHEN ct.LastSyncTime < DATEADD(day, -90, GETDATE()) OR ct.LastSyncTime IS NULL THEN ct.TargetID END) AS NotReportingLast90Days,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS TotalUpdatesNeeded,
    SUM(CASE WHEN us.SummarizationState = 3 THEN 1 ELSE 0 END) AS TotalUpdatesInstalled,
    CAST(
        (SUM(CASE WHEN us.SummarizationState = 3 THEN 1 ELSE 0 END) * 100.0) / 
        NULLIF(SUM(CASE WHEN us.SummarizationState IN (2,3) THEN 1 ELSE 0 END), 0)
    AS DECIMAL(5,2)) AS CompliancePercentage
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
WHERE ct.TargetID IN (SELECT TargetID FROM dbo.tbComputerTarget WHERE TargetID IS NOT NULL)
GO

GRANT SELECT ON vw_OverallCompliance TO PUBLIC
GO
PRINT '[SUCCESS] View 1 created'
PRINT ''

-- =============================================
-- VIEW 2: Compliance By Classification
-- Uses vClassification view that exists in your DB
-- =============================================
PRINT 'Installing View 2 of 6: vw_ComplianceByClassification...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ComplianceByClassification')
    DROP VIEW vw_ComplianceByClassification
GO

CREATE VIEW vw_ComplianceByClassification
AS
SELECT 
    ISNULL(vc.Title, 'Unknown') AS Classification,
    COUNT(DISTINCT ct.TargetID) AS TotalComputers,
    COUNT(DISTINCT CASE WHEN us.SummarizationState = 2 THEN ct.TargetID END) AS ComputersNeedingUpdates,
    COUNT(DISTINCT CASE WHEN us.SummarizationState = 3 THEN ct.TargetID END) AS ComputersCompliant,
    COUNT(DISTINCT CASE WHEN us.SummarizationState IN (4,5,6) THEN ct.TargetID END) AS ComputersWithFailures,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS UpdatesNeeded,
    SUM(CASE WHEN us.SummarizationState = 3 THEN 1 ELSE 0 END) AS UpdatesInstalled,
    CAST(
        (COUNT(DISTINCT CASE WHEN us.SummarizationState = 3 THEN ct.TargetID END) * 100.0) / 
        NULLIF(COUNT(DISTINCT ct.TargetID), 0)
    AS DECIMAL(5,2)) AS CompliancePercentage
FROM dbo.tbComputerTarget ct
INNER JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
INNER JOIN dbo.tbUpdate u ON us.LocalUpdateID = u.LocalUpdateID
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.vClassification vc ON ric.CategoryID = vc.CategoryID
WHERE u.IsHidden = 0
GROUP BY vc.Title
GO

GRANT SELECT ON vw_ComplianceByClassification TO PUBLIC
GO
PRINT '[SUCCESS] View 2 created'
PRINT ''

-- =============================================
-- VIEW 3: Missing Security Updates
-- =============================================
PRINT 'Installing View 3 of 6: vw_MissingSecurityUpdates...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_MissingSecurityUpdates')
    DROP VIEW vw_MissingSecurityUpdates
GO

CREATE VIEW vw_MissingSecurityUpdates
AS
SELECT TOP 100
    u.UpdateID,
    ISNULL(lp.Title, 'Unknown Update') AS UpdateTitle,
    ISNULL(vc.Title, 'Unknown') AS Classification,
    u.CreationDate AS ReleaseDate,
    DATEDIFF(day, u.CreationDate, GETDATE()) AS DaysSinceRelease,
    COUNT(DISTINCT us.TargetID) AS ComputersAffected,
    CASE 
        WHEN vc.Title LIKE '%Critical%' THEN 'Critical'
        WHEN vc.Title LIKE '%Security%' THEN 'High'
        ELSE 'Medium'
    END AS Severity,
    COALESCE(kb.ArticleID, 'N/A') AS KBArticle
FROM dbo.tbUpdate u
INNER JOIN dbo.tbUpdateStatusPerComputer us ON u.LocalUpdateID = us.LocalUpdateID
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.vClassification vc ON ric.CategoryID = vc.CategoryID
LEFT JOIN dbo.tbLocalizedPropertyForRevision lp ON u.LocalUpdateID = lp.RevisionID AND lp.LanguageID = 1033
LEFT JOIN dbo.tbKBArticleForRevision kb ON u.LocalUpdateID = kb.RevisionID
WHERE us.SummarizationState = 2
    AND u.IsHidden = 0
    AND (vc.Title LIKE '%Critical%' OR vc.Title LIKE '%Security%')
GROUP BY u.UpdateID, lp.Title, vc.Title, u.CreationDate, kb.ArticleID
HAVING COUNT(DISTINCT us.TargetID) > 0
ORDER BY COUNT(DISTINCT us.TargetID) DESC
GO

GRANT SELECT ON vw_MissingSecurityUpdates TO PUBLIC
GO
PRINT '[SUCCESS] View 3 created'
PRINT ''

-- =============================================
-- VIEW 4: Non-Reporting Systems
-- Uses tbTargetInTargetGroup (the correct table)
-- =============================================
PRINT 'Installing View 4 of 6: vw_NonReportingSystems...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_NonReportingSystems')
    DROP VIEW vw_NonReportingSystems
GO

CREATE VIEW vw_NonReportingSystems
AS
SELECT 
    ct.FullDomainName AS ComputerName,
    ct.LastSyncTime,
    DATEDIFF(day, ct.LastSyncTime, GETDATE()) AS DaysSinceLastSync,
    ctd.OSDescription AS OperatingSystem,
    ctd.ComputerMake AS Manufacturer,
    ctd.ComputerModel AS Model,
    ct.IPAddress,
    CASE 
        WHEN ct.LastSyncTime IS NULL THEN 'Never Reported'
        WHEN DATEDIFF(day, ct.LastSyncTime, GETDATE()) >= 90 THEN 'Critical (90+ days)'
        WHEN DATEDIFF(day, ct.LastSyncTime, GETDATE()) >= 60 THEN 'High (60-89 days)'
        WHEN DATEDIFF(day, ct.LastSyncTime, GETDATE()) >= 30 THEN 'Medium (30-59 days)'
        ELSE 'Recent'
    END AS Status,
    COALESCE(tg.Name, 'Unassigned') AS ComputerGroup
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN dbo.tbTargetInTargetGroup ttg ON ct.TargetID = ttg.TargetID
LEFT JOIN dbo.tbTargetGroup tg ON ttg.TargetGroupID = tg.TargetGroupID
WHERE (ct.LastSyncTime IS NULL OR ct.LastSyncTime < DATEADD(day, -30, GETDATE()))
GO

GRANT SELECT ON vw_NonReportingSystems TO PUBLIC
GO
PRINT '[SUCCESS] View 4 created'
PRINT ''

-- =============================================
-- VIEW 5: Compliance By System Type
-- =============================================
PRINT 'Installing View 5 of 6: vw_ComplianceBySystemType...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ComplianceBySystemType')
    DROP VIEW vw_ComplianceBySystemType
GO

CREATE VIEW vw_ComplianceBySystemType
AS
SELECT 
    CASE 
        WHEN ctd.OSDescription LIKE '%Server%' THEN 'Server'
        WHEN ctd.OSDescription LIKE '%Windows 10%' THEN 'Windows 10 Workstation'
        WHEN ctd.OSDescription LIKE '%Windows 11%' THEN 'Windows 11 Workstation'
        ELSE 'Other'
    END AS SystemType,
    COUNT(DISTINCT ct.TargetID) AS TotalSystems,
    SUM(CASE WHEN needs.NeedsUpdates > 0 THEN 1 ELSE 0 END) AS SystemsNeedingUpdates,
    SUM(CASE WHEN needs.NeedsUpdates = 0 AND needs.HasUpdates > 0 THEN 1 ELSE 0 END) AS CompliantSystems,
    SUM(CASE WHEN fails.FailedUpdates > 0 THEN 1 ELSE 0 END) AS SystemsWithFailures,
    CAST(
        (SUM(CASE WHEN needs.NeedsUpdates = 0 AND needs.HasUpdates > 0 THEN 1 ELSE 0 END) * 100.0) / 
        NULLIF(COUNT(DISTINCT ct.TargetID), 0)
    AS DECIMAL(5,2)) AS CompliancePercentage,
    SUM(CASE WHEN ct.LastSyncTime >= DATEADD(day, -30, GETDATE()) THEN 1 ELSE 0 END) AS ReportingLast30Days,
    SUM(CASE WHEN ct.LastSyncTime < DATEADD(day, -30, GETDATE()) OR ct.LastSyncTime IS NULL THEN 1 ELSE 0 END) AS NotReportingLast30Days
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN (
    SELECT TargetID, 
           SUM(CASE WHEN SummarizationState = 2 THEN 1 ELSE 0 END) AS NeedsUpdates,
           COUNT(*) AS HasUpdates
    FROM dbo.tbUpdateStatusPerComputer
    GROUP BY TargetID
) needs ON ct.TargetID = needs.TargetID
LEFT JOIN (
    SELECT TargetID, 
           SUM(CASE WHEN SummarizationState IN (4,5,6) THEN 1 ELSE 0 END) AS FailedUpdates
    FROM dbo.tbUpdateStatusPerComputer
    GROUP BY TargetID
) fails ON ct.TargetID = fails.TargetID
GROUP BY 
    CASE 
        WHEN ctd.OSDescription LIKE '%Server%' THEN 'Server'
        WHEN ctd.OSDescription LIKE '%Windows 10%' THEN 'Windows 10 Workstation'
        WHEN ctd.OSDescription LIKE '%Windows 11%' THEN 'Windows 11 Workstation'
        ELSE 'Other'
    END
HAVING COUNT(DISTINCT ct.TargetID) > 0
GO

GRANT SELECT ON vw_ComplianceBySystemType TO PUBLIC
GO
PRINT '[SUCCESS] View 5 created'
PRINT ''

-- =============================================
-- VIEW 6: Top Non-Compliant Systems
-- =============================================
PRINT 'Installing View 6 of 6: vw_TopNonCompliantSystems...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_TopNonCompliantSystems')
    DROP VIEW vw_TopNonCompliantSystems
GO

CREATE VIEW vw_TopNonCompliantSystems
AS
SELECT TOP 100
    ct.FullDomainName AS ComputerName,
    ctd.OSDescription AS OperatingSystem,
    ct.LastSyncTime,
    DATEDIFF(day, ct.LastSyncTime, GETDATE()) AS DaysSinceLastSync,
    SUM(CASE WHEN vc.Title LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingCritical,
    SUM(CASE WHEN vc.Title LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingSecurity,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS TotalMissingUpdates,
    SUM(CASE WHEN us.SummarizationState IN (4,5,6) THEN 1 ELSE 0 END) AS FailedUpdates,
    COALESCE(tg.Name, 'Unassigned') AS ComputerGroup,
    (SUM(CASE WHEN vc.Title LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 10) +
    (SUM(CASE WHEN vc.Title LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 5) +
    (SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END)) AS RiskScore
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
LEFT JOIN dbo.tbUpdate u ON us.LocalUpdateID = u.LocalUpdateID
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.vClassification vc ON ric.CategoryID = vc.CategoryID
LEFT JOIN dbo.tbTargetInTargetGroup ttg ON ct.TargetID = ttg.TargetID
LEFT JOIN dbo.tbTargetGroup tg ON ttg.TargetGroupID = tg.TargetGroupID
WHERE (u.IsHidden = 0 OR u.IsHidden IS NULL)
GROUP BY ct.FullDomainName, ctd.OSDescription, ct.LastSyncTime, tg.Name
HAVING SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) > 0
ORDER BY RiskScore DESC, TotalMissingUpdates DESC
GO

GRANT SELECT ON vw_TopNonCompliantSystems TO PUBLIC
GO
PRINT '[SUCCESS] View 6 created'
PRINT ''

-- =============================================
-- Verification
-- =============================================
PRINT '=========================================='
PRINT 'Verifying Installation...'
PRINT ''

SELECT 
    name AS ViewName,
    create_date AS CreatedDate
FROM sys.views
WHERE name LIKE 'vw_%'
  AND name NOT LIKE 'vw_WSUS%' -- Exclude existing WSUS views
ORDER BY name

PRINT ''
PRINT '=========================================='
PRINT 'Installation Complete!'
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '=========================================='
PRINT ''
PRINT 'SUCCESS: All 6 views created!'
PRINT ''
PRINT 'Now test them:'
PRINT 'SELECT * FROM vw_OverallCompliance'
PRINT 'SELECT * FROM vw_ComplianceByClassification'
PRINT ''
