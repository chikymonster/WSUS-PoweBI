-- =============================================
-- WSUS Reporting Views - COMPLETE INSTALLATION
-- Run this ONE script to install all 6 views
-- =============================================
-- 
-- INSTRUCTIONS:
-- 1. Open this file in SQL Server Management Studio (SSMS)
-- 2. Make sure you're connected to your SQL Server
-- 3. Select "SUSDB" from the database dropdown at the top
-- 4. Press F5 to execute
-- 5. You should see "SUCCESS" messages for all 6 views
--
-- =============================================

USE SUSDB
GO

PRINT '=========================================='
PRINT 'WSUS Reporting Views Installation'
PRINT 'Started: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '=========================================='
PRINT ''

-- =============================================
-- VIEW 1: Overall Compliance
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
WHERE ct.IsRegistered = 1
GO

GRANT SELECT ON vw_OverallCompliance TO PUBLIC
GO

PRINT '[SUCCESS] View 1 created: vw_OverallCompliance'
PRINT ''

-- =============================================
-- VIEW 2: Compliance By Classification
-- =============================================
PRINT 'Installing View 2 of 6: vw_ComplianceByClassification...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ComplianceByClassification')
    DROP VIEW vw_ComplianceByClassification
GO

CREATE VIEW vw_ComplianceByClassification
AS
SELECT 
    uc.Title AS Classification,
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
INNER JOIN dbo.tbClassificationForUpdate cu ON u.LocalUpdateID = cu.LocalUpdateID
INNER JOIN dbo.tbClassification uc ON cu.ClassificationID = uc.ClassificationID
WHERE ct.IsRegistered = 1 AND u.IsHidden = 0
GROUP BY uc.Title
GO

GRANT SELECT ON vw_ComplianceByClassification TO PUBLIC
GO

PRINT '[SUCCESS] View 2 created: vw_ComplianceByClassification'
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
SELECT 
    u.UpdateID,
    p.DefaultTitle AS UpdateTitle,
    uc.Title AS Classification,
    u.ImportedTime AS ReleaseDate,
    DATEDIFF(day, u.ImportedTime, GETDATE()) AS DaysSinceRelease,
    COUNT(DISTINCT us.TargetID) AS ComputersAffected,
    CASE 
        WHEN uc.Title LIKE '%Critical%' THEN 'Critical'
        WHEN uc.Title LIKE '%Security%' THEN 'High'
        ELSE 'Medium'
    END AS Severity,
    COALESCE(ka.KBArticleID, 'N/A') AS KBArticle
FROM dbo.tbUpdate u
INNER JOIN dbo.tbClassificationForUpdate cu ON u.LocalUpdateID = cu.LocalUpdateID
INNER JOIN dbo.tbClassification uc ON cu.ClassificationID = uc.ClassificationID
INNER JOIN dbo.tbLocalizedPropertyForRevision p ON u.LocalUpdateID = p.LocalizedPropertyID
LEFT JOIN dbo.tbKBArticleForRevision ka ON u.LocalUpdateID = ka.RevisionID
INNER JOIN dbo.tbUpdateStatusPerComputer us ON u.LocalUpdateID = us.LocalUpdateID
WHERE us.SummarizationState = 2
    AND u.IsHidden = 0
    AND (uc.Title LIKE '%Critical%' OR uc.Title LIKE '%Security%')
GROUP BY u.UpdateID, p.DefaultTitle, uc.Title, u.ImportedTime, ka.KBArticleID
HAVING COUNT(DISTINCT us.TargetID) > 0
GO

GRANT SELECT ON vw_MissingSecurityUpdates TO PUBLIC
GO

PRINT '[SUCCESS] View 3 created: vw_MissingSecurityUpdates'
PRINT ''

-- =============================================
-- VIEW 4: Non-Reporting Systems
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
LEFT JOIN dbo.tbComputerTargetInTargetGroup ctg ON ct.TargetID = ctg.TargetID
LEFT JOIN dbo.tbTargetGroup tg ON ctg.TargetGroupID = tg.TargetGroupID
WHERE ct.IsRegistered = 1
    AND (ct.LastSyncTime IS NULL OR ct.LastSyncTime < DATEADD(day, -30, GETDATE()))
GO

GRANT SELECT ON vw_NonReportingSystems TO PUBLIC
GO

PRINT '[SUCCESS] View 4 created: vw_NonReportingSystems'
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
        WHEN ctd.OSDescription LIKE '%Windows 7%' THEN 'Windows 7 Workstation'
        WHEN ctd.OSDescription LIKE '%Windows 8%' THEN 'Windows 8 Workstation'
        ELSE 'Other'
    END AS SystemType,
    COUNT(DISTINCT ct.TargetID) AS TotalSystems,
    COUNT(DISTINCT CASE WHEN EXISTS (SELECT 1 FROM dbo.tbUpdateStatusPerComputer us2 WHERE us2.TargetID = ct.TargetID AND us2.SummarizationState = 2) THEN ct.TargetID END) AS SystemsNeedingUpdates,
    COUNT(DISTINCT CASE WHEN NOT EXISTS (SELECT 1 FROM dbo.tbUpdateStatusPerComputer us2 WHERE us2.TargetID = ct.TargetID AND us2.SummarizationState = 2) AND EXISTS (SELECT 1 FROM dbo.tbUpdateStatusPerComputer us2 WHERE us2.TargetID = ct.TargetID) THEN ct.TargetID END) AS CompliantSystems,
    COUNT(DISTINCT CASE WHEN EXISTS (SELECT 1 FROM dbo.tbUpdateStatusPerComputer us2 WHERE us2.TargetID = ct.TargetID AND us2.SummarizationState IN (4,5,6)) THEN ct.TargetID END) AS SystemsWithFailures,
    CAST((COUNT(DISTINCT CASE WHEN NOT EXISTS (SELECT 1 FROM dbo.tbUpdateStatusPerComputer us2 WHERE us2.TargetID = ct.TargetID AND us2.SummarizationState = 2) AND EXISTS (SELECT 1 FROM dbo.tbUpdateStatusPerComputer us2 WHERE us2.TargetID = ct.TargetID) THEN ct.TargetID END) * 100.0) / NULLIF(COUNT(DISTINCT ct.TargetID), 0) AS DECIMAL(5,2)) AS CompliancePercentage,
    COUNT(DISTINCT CASE WHEN ct.LastSyncTime >= DATEADD(day, -30, GETDATE()) THEN ct.TargetID END) AS ReportingLast30Days,
    COUNT(DISTINCT CASE WHEN ct.LastSyncTime < DATEADD(day, -30, GETDATE()) OR ct.LastSyncTime IS NULL THEN ct.TargetID END) AS NotReportingLast30Days
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
WHERE ct.IsRegistered = 1
GROUP BY 
    CASE 
        WHEN ctd.OSDescription LIKE '%Server%' THEN 'Server'
        WHEN ctd.OSDescription LIKE '%Windows 10%' THEN 'Windows 10 Workstation'
        WHEN ctd.OSDescription LIKE '%Windows 11%' THEN 'Windows 11 Workstation'
        WHEN ctd.OSDescription LIKE '%Windows 7%' THEN 'Windows 7 Workstation'
        WHEN ctd.OSDescription LIKE '%Windows 8%' THEN 'Windows 8 Workstation'
        ELSE 'Other'
    END
HAVING COUNT(DISTINCT ct.TargetID) > 0
GO

GRANT SELECT ON vw_ComplianceBySystemType TO PUBLIC
GO

PRINT '[SUCCESS] View 5 created: vw_ComplianceBySystemType'
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
    SUM(CASE WHEN uc.Title LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingCritical,
    SUM(CASE WHEN uc.Title LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingSecurity,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS TotalMissingUpdates,
    SUM(CASE WHEN us.SummarizationState IN (4,5,6) THEN 1 ELSE 0 END) AS FailedUpdates,
    COALESCE(tg.Name, 'Unassigned') AS ComputerGroup,
    (SUM(CASE WHEN uc.Title LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 10) +
    (SUM(CASE WHEN uc.Title LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 5) +
    (SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END)) AS RiskScore
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
LEFT JOIN dbo.tbUpdate u ON us.LocalUpdateID = u.LocalUpdateID
LEFT JOIN dbo.tbClassificationForUpdate cu ON u.LocalUpdateID = cu.LocalUpdateID
LEFT JOIN dbo.tbClassification uc ON cu.ClassificationID = uc.ClassificationID
LEFT JOIN dbo.tbComputerTargetInTargetGroup ctg ON ct.TargetID = ctg.TargetID
LEFT JOIN dbo.tbTargetGroup tg ON ctg.TargetGroupID = tg.TargetGroupID
WHERE ct.IsRegistered = 1 AND (u.IsHidden = 0 OR u.IsHidden IS NULL)
GROUP BY ct.FullDomainName, ctd.OSDescription, ct.LastSyncTime, tg.Name
HAVING SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) > 0
ORDER BY RiskScore DESC, TotalMissingUpdates DESC
GO

GRANT SELECT ON vw_TopNonCompliantSystems TO PUBLIC
GO

PRINT '[SUCCESS] View 6 created: vw_TopNonCompliantSystems'
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
ORDER BY name

PRINT ''
PRINT '=========================================='
PRINT 'Installation Complete!'
PRINT 'Finished: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '=========================================='
PRINT ''
PRINT 'All 6 views have been created successfully.'
PRINT 'You can now connect Power BI to these views.'
PRINT ''
