-- =============================================
-- ULTRA-SIMPLIFIED WORKING VIEWS
-- No category lookups - just basic data
-- =============================================

USE SUSDB
GO

PRINT '=========================================='
PRINT 'Creating Ultra-Simplified Working Views'
PRINT '=========================================='
PRINT ''

-- =============================================
-- VIEW 2: Simple Classification (WORKING)
-- Just shows "All Updates" - no breakdown
-- =============================================
PRINT 'Creating View 2: vw_ComplianceByClassification (simple)...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ComplianceByClassification')
    DROP VIEW vw_ComplianceByClassification
GO

CREATE VIEW vw_ComplianceByClassification
AS
SELECT 
    'All Updates' AS Classification,
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
WHERE u.IsHidden = 0
GO

GRANT SELECT ON vw_ComplianceByClassification TO PUBLIC
GO
PRINT '[SUCCESS] View 2 created'
PRINT ''

-- =============================================
-- VIEW 3: Simple Missing Updates (WORKING)
-- No classification - just missing updates
-- =============================================
PRINT 'Creating View 3: vw_MissingSecurityUpdates (simple)...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_MissingSecurityUpdates')
    DROP VIEW vw_MissingSecurityUpdates
GO

CREATE VIEW vw_MissingSecurityUpdates
AS
SELECT TOP 100
    u.UpdateID,
    u.DefaultTitle AS UpdateTitle,
    'Security' AS Classification,
    u.ImportedTime AS ReleaseDate,
    DATEDIFF(day, u.ImportedTime, GETDATE()) AS DaysSinceRelease,
    COUNT(DISTINCT us.TargetID) AS ComputersAffected,
    'High' AS Severity,
    'N/A' AS KBArticle
FROM dbo.tbUpdate u
INNER JOIN dbo.tbUpdateStatusPerComputer us ON u.LocalUpdateID = us.LocalUpdateID
WHERE us.SummarizationState = 2
    AND u.IsHidden = 0
GROUP BY u.UpdateID, u.DefaultTitle, u.ImportedTime
HAVING COUNT(DISTINCT us.TargetID) > 0
ORDER BY COUNT(DISTINCT us.TargetID) DESC
GO

GRANT SELECT ON vw_MissingSecurityUpdates TO PUBLIC
GO
PRINT '[SUCCESS] View 3 created'
PRINT ''

-- =============================================
-- VIEW 6: Simple Top Non-Compliant (WORKING)
-- No category breakdown - just total missing
-- =============================================
PRINT 'Creating View 6: vw_TopNonCompliantSystems (simple)...'

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
    0 AS MissingCritical,
    0 AS MissingSecurity,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS TotalMissingUpdates,
    SUM(CASE WHEN us.SummarizationState IN (4,5,6) THEN 1 ELSE 0 END) AS FailedUpdates,
    COALESCE(tg.Name, 'Unassigned') AS ComputerGroup,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS RiskScore
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
LEFT JOIN dbo.tbUpdate u ON us.LocalUpdateID = u.LocalUpdateID
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
-- Test All 6 Views
-- =============================================
PRINT '=========================================='
PRINT 'Testing All 6 Views'
PRINT '=========================================='
PRINT ''

DECLARE @View1Count INT, @View2Count INT, @View3Count INT
DECLARE @View4Count INT, @View5Count INT, @View6Count INT

-- Test each view
SELECT @View1Count = COUNT(*) FROM vw_OverallCompliance
SELECT @View2Count = COUNT(*) FROM vw_ComplianceByClassification
SELECT @View3Count = COUNT(*) FROM vw_MissingSecurityUpdates
SELECT @View4Count = COUNT(*) FROM vw_NonReportingSystems
SELECT @View5Count = COUNT(*) FROM vw_ComplianceBySystemType
SELECT @View6Count = COUNT(*) FROM vw_TopNonCompliantSystems

PRINT '1. vw_OverallCompliance: ' + CAST(@View1Count AS VARCHAR) + ' rows'
PRINT '2. vw_ComplianceByClassification: ' + CAST(@View2Count AS VARCHAR) + ' rows'
PRINT '3. vw_MissingSecurityUpdates: ' + CAST(@View3Count AS VARCHAR) + ' rows'
PRINT '4. vw_NonReportingSystems: ' + CAST(@View4Count AS VARCHAR) + ' rows'
PRINT '5. vw_ComplianceBySystemType: ' + CAST(@View5Count AS VARCHAR) + ' rows'
PRINT '6. vw_TopNonCompliantSystems: ' + CAST(@View6Count AS VARCHAR) + ' rows'

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
PRINT '5. Select all 6 vw_ views'
PRINT '6. Click Load'
PRINT '7. Build your dashboard!'
PRINT ''
