-- =============================================
-- WSUS Database Schema Discovery Script
-- Run this in SSMS to find the actual column names
-- =============================================

USE SUSDB
GO

PRINT '=========================================='
PRINT 'WSUS Table Schema Discovery'
PRINT '=========================================='
PRINT ''

-- Check tbComputerTarget columns
PRINT '1. tbComputerTarget columns:'
PRINT '------------------------------------------'
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tbComputerTarget'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '2. tbComputerTargetDetail columns:'
PRINT '------------------------------------------'
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tbComputerTargetDetail'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '3. tbUpdateStatusPerComputer columns:'
PRINT '------------------------------------------'
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tbUpdateStatusPerComputer'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '4. tbUpdate columns:'
PRINT '------------------------------------------'
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tbUpdate'
ORDER BY ORDINAL_POSITION
GO

PRINT ''
PRINT '5. Sample data from tbComputerTarget (first 5 rows):'
PRINT '------------------------------------------'
SELECT TOP 5 *
FROM tbComputerTarget
GO

PRINT ''
PRINT '6. Sample data from tbComputerTargetDetail (first 5 rows):'
PRINT '------------------------------------------'
SELECT TOP 5 *
FROM tbComputerTargetDetail
GO

PRINT ''
PRINT '=========================================='
PRINT 'Discovery Complete!'
PRINT 'Send these results to fix the SQL views'
PRINT '=========================================='
