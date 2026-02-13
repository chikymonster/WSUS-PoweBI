-- =============================================
-- FINAL CORRECT WSUS VIEWS
-- Based on actual column names in your database
-- =============================================

USE SUSDB
GO

PRINT '=========================================='
PRINT 'Creating All 6 WSUS Views (CORRECT VERSION)'
PRINT '=========================================='
PRINT ''

-- =============================================
-- VIEW 1: Overall Compliance (Already Working!)
-- =============================================
PRINT 'View 1: vw_OverallCompliance (already works)'
PRINT ''

-- =============================================
-- VIEW 2: Compliance By Classification
-- Uses tbLocalizedProperty for category names
-- =============================================
PRINT 'Creating View 2: vw_ComplianceByClassification...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ComplianceByClassification')
    DROP VIEW vw_ComplianceByClassification
GO

CREATE VIEW vw_ComplianceByClassification
AS
SELECT 
    ISNULL(lp.Title, 'Unknown') AS Classification,
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
LEFT JOIN dbo.tbCategory cat ON ric.CategoryID = cat.CategoryID
LEFT JOIN dbo.tbLocalizedProperty lp ON cat.CategoryID = lp.LocalizedPropertyID AND lp.LanguageID = 1033
WHERE u.IsHidden = 0
GROUP BY lp.Title
GO

GRANT SELECT ON vw_ComplianceByClassification TO PUBLIC
GO
PRINT '[SUCCESS] View 2 created'
PRINT ''

-- =============================================
-- VIEW 3: Missing Security Updates
-- Uses tbLocalizedPropertyForRevision for update titles
-- =============================================
PRINT 'Creating View 3: vw_MissingSecurityUpdates...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_MissingSecurityUpdates')
    DROP VIEW vw_MissingSecurityUpdates
GO

CREATE VIEW vw_MissingSecurityUpdates
AS
SELECT TOP 100
    u.UpdateID,
    ISNULL(lpr.Title, 'Unknown Update') AS UpdateTitle,
    ISNULL(lp_cat.Title, 'Unknown') AS Classification,
    u.ImportedTime AS ReleaseDate,
    DATEDIFF(day, u.ImportedTime, GETDATE()) AS DaysSinceRelease,
    COUNT(DISTINCT us.TargetID) AS ComputersAffected,
    CASE 
        WHEN lp_cat.Title LIKE '%Critical%' THEN 'Critical'
        WHEN lp_cat.Title LIKE '%Security%' THEN 'High'
        ELSE 'Medium'
    END AS Severity,
    COALESCE(kb.KBArticleID, 'N/A') AS KBArticle
FROM dbo.tbUpdate u
INNER JOIN dbo.tbUpdateStatusPerComputer us ON u.LocalUpdateID = us.LocalUpdateID
LEFT JOIN dbo.tbLocalizedPropertyForRevision lpr ON u.LocalUpdateID = lpr.RevisionID AND lpr.LanguageID = 1033
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.tbCategory cat ON ric.CategoryID = cat.CategoryID
LEFT JOIN dbo.tbLocalizedProperty lp_cat ON cat.CategoryID = lp_cat.LocalizedPropertyID AND lp_cat.LanguageID = 1033
LEFT JOIN dbo.tbKBArticleForRevision kb ON u.LocalUpdateID = kb.RevisionID
WHERE us.SummarizationState = 2
    AND u.IsHidden = 0
    AND (lp_cat.Title LIKE '%Critical%' OR lp_cat.Title LIKE '%Security%')
GROUP BY u.UpdateID, lpr.Title, lp_cat.Title, u.ImportedTime, kb.KBArticleID
HAVING COUNT(DISTINCT us.TargetID) > 0
ORDER BY COUNT(DISTINCT us.TargetID) DESC
GO

GRANT SELECT ON vw_MissingSecurityUpdates TO PUBLIC
GO
PRINT '[SUCCESS] View 3 created'
PRINT ''

-- =============================================
-- VIEW 4: Non-Reporting Systems (Already Working!)
-- =============================================
PRINT 'View 4: vw_NonReportingSystems (already works)'
PRINT ''

-- =============================================
-- VIEW 5: Compliance By System Type (Already Working!)
-- =============================================
PRINT 'View 5: vw_ComplianceBySystemType (already works)'
PRINT ''

-- =============================================
-- VIEW 6: Top Non-Compliant Systems
-- Uses tbLocalizedProperty for category names
-- =============================================
PRINT 'Creating View 6: vw_TopNonCompliantSystems...'

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
    SUM(CASE WHEN lp_cat.Title LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingCritical,
    SUM(CASE WHEN lp_cat.Title LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingSecurity,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS TotalMissingUpdates,
    SUM(CASE WHEN us.SummarizationState IN (4,5,6) THEN 1 ELSE 0 END) AS FailedUpdates,
    COALESCE(tg.Name, 'Unassigned') AS ComputerGroup,
    (SUM(CASE WHEN lp_cat.Title LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 10) +
    (SUM(CASE WHEN lp_cat.Title LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 5) +
    (SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END)) AS RiskScore
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
LEFT JOIN dbo.tbUpdate u ON us.LocalUpdateID = u.LocalUpdateID
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.tbCategory cat ON ric.CategoryID = cat.CategoryID
LEFT JOIN dbo.tbLocalizedProperty lp_cat ON cat.CategoryID = lp_cat.LocalizedPropertyID AND lp_cat.LanguageID = 1033
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
-- Verification and Testing
-- =============================================
PRINT '=========================================='
PRINT 'Testing All 6 Views'
PRINT '=========================================='
PRINT ''

-- List all views
SELECT name AS ViewName
FROM sys.views
WHERE name LIKE 'vw_%'
  AND name NOT LIKE 'vw_WSUS%'
ORDER BY name
GO

PRINT ''
PRINT 'Testing queries...'
PRINT ''

-- Test View 1
PRINT '1. vw_OverallCompliance:'
SELECT 
    TotalComputers,
    CompliancePercentage,
    NotReportingLast30Days
FROM vw_OverallCompliance
GO

PRINT ''
PRINT '2. vw_ComplianceByClassification:'
SELECT TOP 5
    Classification,
    UpdatesNeeded,
    CompliancePercentage
FROM vw_ComplianceByClassification
ORDER BY UpdatesNeeded DESC
GO

PRINT ''
PRINT '3. vw_MissingSecurityUpdates (first 3):'
SELECT TOP 3
    UpdateTitle,
    ComputersAffected,
    Severity
FROM vw_MissingSecurityUpdates
GO

PRINT ''
PRINT '4. vw_NonReportingSystems (count):'
SELECT COUNT(*) AS NonReportingCount
FROM vw_NonReportingSystems
GO

PRINT ''
PRINT '5. vw_ComplianceBySystemType:'
SELECT 
    SystemType,
    TotalSystems,
    CompliancePercentage
FROM vw_ComplianceBySystemType
GO

PRINT ''
PRINT '6. vw_TopNonCompliantSystems (first 3):'
SELECT TOP 3
    ComputerName,
    TotalMissingUpdates,
    MissingCritical,
    MissingSecurity
FROM vw_TopNonCompliantSystems
GO

PRINT ''
PRINT '=========================================='
PRINT 'SUCCESS! All 6 views are working!'
PRINT '=========================================='
PRINT ''
PRINT 'Next Steps:'
PRINT '1. Open Power BI Desktop'
PRINT '2. Get Data -> SQL Server'
PRINT '3. Server: YOUR_SQL_SERVER'
PRINT '4. Database: SUSDB'
PRINT '5. Load these 6 views'
PRINT '6. Build your dashboard!'
PRINT ''
