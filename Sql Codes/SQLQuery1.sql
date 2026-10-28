BULK INSERT dbo.p1_2018q1
FROM 'C:\Job Files\Projects\Delinquency Roll-Rate & Collections Prioritization\Datasets\Filtered-2018Q1.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);

