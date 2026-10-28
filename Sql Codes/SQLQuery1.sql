-- Creating table for inserting the whole 2018 q1 dataset and also for column placement
CREATE TABLE dbo.p1_2018q1
(
    LOAN_ID                       VARCHAR(50),
    ACT_PERIOD                    VARCHAR(20),
    ORIG_DATE                     VARCHAR(20),
    FIRST_PAY                     VARCHAR(20),
    ORIG_RATE                     VARCHAR(30),
    CURR_RATE                     VARCHAR(30),
    ORIG_UPB                      VARCHAR(30),
    CURRENT_UPB                   VARCHAR(30),
    LOAN_AGE                       VARCHAR(20),
    OLTV                          VARCHAR(20),
    OCLTV                         VARCHAR(20),
    DTI                           VARCHAR(20),
    CSCORE_B                      VARCHAR(20),
    PURPOSE                       VARCHAR(20),
    OCC_STAT                      VARCHAR(20),
    STATE                         VARCHAR(10),
    PRODUCT                       VARCHAR(50),
    DLQ_STATUS                    VARCHAR(20),
    Zero_Bal_Code                 VARCHAR(20),
    ZB_DTE                        VARCHAR(20),
    MOD_FLAG                      VARCHAR(10),
    HOMEREADY_PROGRAM_INDICATOR   VARCHAR(10)
);

--bulk inserting the whole dataset into ssms

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
