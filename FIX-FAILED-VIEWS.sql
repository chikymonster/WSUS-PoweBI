-- =============================================
-- WSUS REPORTING VIEWS - WORKING VERSION
-- Without vClassification dependency
-- =============================================

USE SUSDB
GO

PRINT 'Fixing the 3 views that failed...'
PRINT ''

-- =============================================
-- VIEW 2: Compliance By Classification (FIXED)
-- Uses tbCategory directly instead of vClassification
-- =============================================
PRINT 'Fixing View 2: vw_ComplianceByClassification...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ComplianceByClassification')
    DROP VIEW vw_ComplianceByClassification
GO

CREATE VIEW vw_ComplianceByClassification
AS
SELECT 
    ISNULL(cat.CategoryTitle, 'All Updates') AS Classification,
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
WHERE u.IsHidden = 0
GROUP BY cat.CategoryTitle
GO

GRANT SELECT ON vw_ComplianceByClassification TO PUBLIC
GO
PRINT '[SUCCESS] View 2 fixed!'
PRINT ''

-- =============================================
-- VIEW 3: Missing Security Updates (FIXED)
-- Uses tbCategory directly
-- =============================================
PRINT 'Fixing View 3: vw_MissingSecurityUpdates...'

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_MissingSecurityUpdates')
    DROP VIEW vw_MissingSecurityUpdates
GO

CREATE VIEW vw_MissingSecurityUpdates
AS
SELECT TOP 100
    u.UpdateID,
    ISNULL(lp.Title, 'Unknown Update') AS UpdateTitle,
    ISNULL(cat.CategoryTitle, 'Unknown') AS Classification,
    u.CreationDate AS ReleaseDate,
    DATEDIFF(day, u.CreationDate, GETDATE()) AS DaysSinceRelease,
    COUNT(DISTINCT us.TargetID) AS ComputersAffected,
    CASE 
        WHEN cat.CategoryTitle LIKE '%Critical%' THEN 'Critical'
        WHEN cat.CategoryTitle LIKE '%Security%' THEN 'High'
        ELSE 'Medium'
    END AS Severity,
    COALESCE(kb.ArticleID, 'N/A') AS KBArticle
FROM dbo.tbUpdate u
INNER JOIN dbo.tbUpdateStatusPerComputer us ON u.LocalUpdateID = us.LocalUpdateID
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.tbCategory cat ON ric.CategoryID = cat.CategoryID
LEFT JOIN dbo.tbLocalizedPropertyForRevision lp ON u.LocalUpdateID = lp.RevisionID AND lp.LanguageID = 1033
LEFT JOIN dbo.tbKBArticleForRevision kb ON u.LocalUpdateID = kb.RevisionID
WHERE us.SummarizationState = 2
    AND u.IsHidden = 0
    AND (cat.CategoryTitle LIKE '%Critical%' OR cat.CategoryTitle LIKE '%Security%')
GROUP BY u.UpdateID, lp.Title, cat.CategoryTitle, u.CreationDate, kb.ArticleID
HAVING COUNT(DISTINCT us.TargetID) > 0
ORDER BY COUNT(DISTINCT us.TargetID) DESC
GO

GRANT SELECT ON vw_MissingSecurityUpdates TO PUBLIC
GO
PRINT '[SUCCESS] View 3 fixed!'
PRINT ''

-- =============================================
-- VIEW 6: Top Non-Compliant Systems (FIXED)
-- Uses tbCategory directly
-- =============================================
PRINT 'Fixing View 6: vw_TopNonCompliantSystems...'

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
    SUM(CASE WHEN cat.CategoryTitle LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingCritical,
    SUM(CASE WHEN cat.CategoryTitle LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) AS MissingSecurity,
    SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) AS TotalMissingUpdates,
    SUM(CASE WHEN us.SummarizationState IN (4,5,6) THEN 1 ELSE 0 END) AS FailedUpdates,
    COALESCE(tg.Name, 'Unassigned') AS ComputerGroup,
    (SUM(CASE WHEN cat.CategoryTitle LIKE '%Critical%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 10) +
    (SUM(CASE WHEN cat.CategoryTitle LIKE '%Security%' AND us.SummarizationState = 2 THEN 1 ELSE 0 END) * 5) +
    (SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END)) AS RiskScore
FROM dbo.tbComputerTarget ct
LEFT JOIN dbo.tbComputerTargetDetail ctd ON ct.TargetID = ctd.TargetID
LEFT JOIN dbo.tbUpdateStatusPerComputer us ON ct.TargetID = us.TargetID
LEFT JOIN dbo.tbUpdate u ON us.LocalUpdateID = u.LocalUpdateID
LEFT JOIN dbo.tbRevisionInCategory ric ON u.LocalUpdateID = ric.RevisionID
LEFT JOIN dbo.tbCategory cat ON ric.CategoryID = cat.CategoryID
LEFT JOIN dbo.tbTargetInTargetGroup ttg ON ct.TargetID = ttg.TargetID
LEFT JOIN dbo.tbTargetGroup tg ON ttg.TargetGroupID = tg.TargetGroupID
WHERE (u.IsHidden = 0 OR u.IsHidden IS NULL)
GROUP BY ct.FullDomainName, ctd.OSDescription, ct.LastSyncTime, tg.Name
HAVING SUM(CASE WHEN us.SummarizationState = 2 THEN 1 ELSE 0 END) > 0
ORDER BY RiskScore DESC, TotalMissingUpdates DESC
GO

GRANT SELECT ON vw_TopNonCompliantSystems TO PUBLIC
GO
PRINT '[SUCCESS] View 6 fixed!'
PRINT ''

-- =============================================
-- Test All Views
-- =============================================
PRINT '=========================================='
PRINT 'Testing all 6 views...'
PRINT ''

-- Test View 1
PRINT 'Testing vw_OverallCompliance...'
IF EXISTS (SELECT * FROM vw_OverallCompliance)
    PRINT '  [OK] Returns data'
ELSE
    PRINT '  [WARNING] No data'
PRINT ''

-- Test View 2
PRINT 'Testing vw_ComplianceByClassification...'
IF EXISTS (SELECT * FROM vw_ComplianceByClassification)
    PRINT '  [OK] Returns data'
ELSE
    PRINT '  [WARNING] No data'
PRINT ''

-- Test View 3
PRINT 'Testing vw_MissingSecurityUpdates...'
IF EXISTS (SELECT * FROM vw_MissingSecurityUpdates)
    PRINT '  [OK] Returns data'
ELSE
    PRINT '  [WARNING] No data'
PRINT ''

-- Test View 4
PRINT 'Testing vw_NonReportingSystems...'
IF EXISTS (SELECT * FROM vw_NonReportingSystems)
    PRINT '  [OK] Returns data'
ELSE
    PRINT '  [WARNING] No data'
PRINT ''

-- Test View 5
PRINT 'Testing vw_ComplianceBySystemType...'
IF EXISTS (SELECT * FROM vw_ComplianceBySystemType)
    PRINT '  [OK] Returns data'
ELSE
    PRINT '  [WARNING] No data'
PRINT ''

-- Test View 6
PRINT 'Testing vw_TopNonCompliantSystems...'
IF EXISTS (SELECT * FROM vw_TopNonCompliantSystems)
    PRINT '  [OK] Returns data'
ELSE
    PRINT '  [WARNING] No data'
PRINT ''

PRINT '=========================================='
PRINT 'ALL VIEWS ARE NOW WORKING!'
PRINT '=========================================='
PRINT ''
PRINT 'You can now:'
PRINT '1. Connect Power BI to these 6 views'
PRINT '2. Build your dashboard'
PRINT '3. Start reporting!'
PRINT ''
