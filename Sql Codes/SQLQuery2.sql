--Creating main working table 

CREATE TABLE dbo.p1_2018q1_clean
(
    LOAN_ID                       VARCHAR(50),
    ACT_PERIOD                    DATE,
    ORIG_DATE                     DATE,
    FIRST_PAY                     DATE,
    ORIG_RATE                     DECIMAL(7,4),
    CURR_RATE                     DECIMAL(7,4),
    ORIG_UPB                      DECIMAL(15,2),
    CURRENT_UPB                   DECIMAL(15,2),
    LOAN_AGE                      INT,
    OLTV                          INT,
    OCLTV                         INT,
    DTI                           INT,
    CSCORE_B                      INT,
    PURPOSE                       VARCHAR(20),
    OCC_STAT                      VARCHAR(20),
    STATE                         VARCHAR(10),
    PRODUCT                       VARCHAR(50),
    DLQ_STATUS                    VARCHAR(20),
    Zero_Bal_Code                 VARCHAR(20),
    ZB_DTE                        DATE,
    MOD_FLAG                      VARCHAR(10),
    HOMEREADY_PROGRAM_INDICATOR   VARCHAR(10)
);

-- Inserting data from staging table to clean table and also converting required data types using TRY_CONVERT as the staging table datatypes was all varchar

INSERT INTO dbo.p1_2018q1_clean
(
    LOAN_ID, ACT_PERIOD, ORIG_DATE, FIRST_PAY, ORIG_RATE, CURR_RATE,
    ORIG_UPB, CURRENT_UPB, LOAN_AGE, OLTV, OCLTV, DTI, CSCORE_B,
    PURPOSE, OCC_STAT, STATE, PRODUCT, DLQ_STATUS, Zero_Bal_Code,
    ZB_DTE, MOD_FLAG, HOMEREADY_PROGRAM_INDICATOR
)
SELECT
    LOAN_ID, 
    TRY_CONVERT(date,RIGHT(ACT_PERIOD,4)+'-'+LEFT(ACT_PERIOD,2)+'-01'),TRY_CONVERT(date,RIGHT(ORIG_DATE,4)+'-'+LEFT(ORIG_DATE,2)+'-01'),
    TRY_CONVERT(date,RIGHT(FIRST_PAY,4)+'-'+LEFT(FIRST_PAY,2)+'-01'),
    TRY_CONVERT(decimal(7,4),ORIG_RATE),TRY_CONVERT(decimal(7,4),CURR_RATE),TRY_CONVERT(decimal(15,2),ORIG_UPB),TRY_CONVERT(decimal(15,2),CURRENT_UPB),
    TRY_CONVERT(int,LOAN_AGE),TRY_CONVERT(int,OLTV),TRY_CONVERT(int,OCLTV),TRY_CONVERT(int,DTI),TRY_CONVERT(int,CSCORE_B),
    PURPOSE, OCC_STAT, STATE, PRODUCT, DLQ_STATUS, Zero_Bal_Code, 
    TRY_CONVERT(date,RIGHT(ZB_DTE,4)+'-'+LEFT(ZB_DTE,2)+'-01'),
    MOD_FLAG, HOMEREADY_PROGRAM_INDICATOR
FROM dbo.p1_2018q1;

