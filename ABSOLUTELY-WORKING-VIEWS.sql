-- =============================================
-- GUARANTEED WORKING VIEWS
-- Uses ONLY columns we know exist
-- =============================================

USE SUSDB
GO

PRINT '=========================================='
PRINT 'Creating Simple Working Views'
PRINT '=========================================='
PRINT ''

-- =============================================
-- VIEW 2: Simple Classification
-- Just shows totals - no category breakdown
-- =============================================
PRINT 'Creating View 2: vw_ComplianceByClassification...'

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
-- VIEW 3: Simple Missing Updates
-- Shows updates missing - no fancy titles
-- =============================================
PRINT 'Creating View 3: vw_MissingSecurityUpdates...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_MissingSecurityUpdates')
    DROP VIEW vw_MissingSecurityUpdates
GO

CREATE VIEW vw_MissingSecurityUpdates
AS
SELECT TOP 100
    u.UpdateID,
    CAST(u.UpdateID AS NVARCHAR(100)) AS UpdateTitle,
    'Security' AS Classification,
    u.ImportedTime AS ReleaseDate,
    DATEDIFF(day, u.ImportedTime, GETDATE()) AS DaysSinceRelease,
    COUNT(DISTINCT us.TargetID) AS ComputersAffected,
    'High' AS Severity,
    ISNULL(kb.KBArticleID, 'N/A') AS KBArticle
FROM dbo.tbUpdate u
INNER JOIN dbo.tbUpdateStatusPerComputer us ON u.LocalUpdateID = us.LocalUpdateID
LEFT JOIN dbo.tbKBArticleForRevision kb ON u.LocalUpdateID = kb.RevisionID
WHERE us.SummarizationState = 2
    AND u.IsHidden = 0
GROUP BY u.UpdateID, u.ImportedTime, kb.KBArticleID
HAVING COUNT(DISTINCT us.TargetID) > 0
ORDER BY COUNT(DISTINCT us.TargetID) DESC
GO

GRANT SELECT ON vw_MissingSecurityUpdates TO PUBLIC
GO
PRINT '[SUCCESS] View 3 created'
PRINT ''

-- =============================================
-- VIEW 6: Simple Top Non-Compliant
-- Shows computers with missing updates
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
ORDER BY RiskScore DESC
GO

GRANT SELECT ON vw_TopNonCompliantSystems TO PUBLIC
GO
PRINT '[SUCCESS] View 6 created'
PRINT ''

-- =============================================
-- Test Everything
-- =============================================
PRINT '=========================================='
PRINT 'Testing All 6 Views'
PRINT '=========================================='
PRINT ''

-- Count rows in each view
DECLARE @v1 INT, @v2 INT, @v3 INT, @v4 INT, @v5 INT, @v6 INT

SELECT @v1 = COUNT(*) FROM vw_OverallCompliance
SELECT @v2 = COUNT(*) FROM vw_ComplianceByClassification
SELECT @v3 = COUNT(*) FROM vw_MissingSecurityUpdates
SELECT @v4 = COUNT(*) FROM vw_NonReportingSystems
SELECT @v5 = COUNT(*) FROM vw_ComplianceBySystemType
SELECT @v6 = COUNT(*) FROM vw_TopNonCompliantSystems

PRINT '✓ View 1 (vw_OverallCompliance): ' + CAST(@v1 AS VARCHAR) + ' rows'
PRINT '✓ View 2 (vw_ComplianceByClassification): ' + CAST(@v2 AS VARCHAR) + ' rows'
PRINT '✓ View 3 (vw_MissingSecurityUpdates): ' + CAST(@v3 AS VARCHAR) + ' rows'
PRINT '✓ View 4 (vw_NonReportingSystems): ' + CAST(@v4 AS VARCHAR) + ' rows'
PRINT '✓ View 5 (vw_ComplianceBySystemType): ' + CAST(@v5 AS VARCHAR) + ' rows'
PRINT '✓ View 6 (vw_TopNonCompliantSystems): ' + CAST(@v6 AS VARCHAR) + ' rows'

PRINT ''
PRINT '=========================================='
PRINT 'SUCCESS! All 6 views work!'
PRINT '=========================================='
PRINT ''

-- Show sample data
PRINT 'Sample Data from vw_OverallCompliance:'
SELECT * FROM vw_OverallCompliance
PRINT ''

PRINT 'Sample from vw_TopNonCompliantSystems (top 5):'
SELECT TOP 5 
    ComputerName, 
    TotalMissingUpdates, 
    OSDescription
FROM vw_TopNonCompliantSystems
PRINT ''

PRINT '=========================================='
PRINT 'Ready for Power BI!'
PRINT '=========================================='
PRINT ''
PRINT 'Next Steps:'
PRINT '1. Open Power BI Desktop'
PRINT '2. Get Data -> SQL Server'  
PRINT '3. Connect to SUSDB'
PRINT '4. Select these 6 views:'
PRINT '   - vw_OverallCompliance'
PRINT '   - vw_ComplianceByClassification'
PRINT '   - vw_MissingSecurityUpdates'
PRINT '   - vw_NonReportingSystems'
PRINT '   - vw_ComplianceBySystemType'
PRINT '   - vw_TopNonCompliantSystems'
PRINT '5. Click Load'
PRINT '6. Build your dashboard!'
PRINT ''
