
-- PHASE 2 — Clean Table
-- Creating main working table 


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


-- Inserting data from staging table to clean working table and also converting required data types using TRY_CONVERT as the staging table datatypes was all varchar


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

-- PHASE 3 — Delinquency Episodes
-- STEP 1:Classifying each monthly row as delequent, not delequent and unknown


SELECT 
CASE 
WHEN DLQ_STATUS = '00' THEN 'Current'
WHEN DLQ_STATUS = 'XX' OR DLQ_STATUS = '' OR DLQ_STATUS IS NULL THEN 'Unknown'
ELSE 'Delinquent'
END AS Classifying_delinquent
FROM p1_2018q1_clean;


-- STEP 2:Using lag() window function to find the previous DLQ_STATUS and months_gap


SELECT TOP(1000) LOAN_ID, ACT_PERIOD, ORIG_DATE, FIRST_PAY, ORIG_RATE, CURR_RATE, ORIG_UPB, CURRENT_UPB, LOAN_AGE ,HOMEREADY_PROGRAM_INDICATOR,DLQ_STATUS,
LAG(DLQ_STATUS) OVER (PARTITION BY LOAN_ID ORDER BY ACT_PERIOD ASC) AS previous_DLQ_STATUS,
DATEDIFF(MONTH, LAG(ACT_PERIOD) OVER (PARTITION BY LOAN_ID ORDER BY ACT_PERIOD ASC), ACT_PERIOD) AS months_gap
FROM p1_2018q1_clean


-- STEP 3:Flagging a row where an episode starts

SELECT LOAN_ID, ACT_PERIOD, DLQ_STATUS, previous_DLQ_STATUS, months_gap, Classifying_delinquent,
CASE WHEN Classifying_delinquent = 'Delinquent' AND previous_DLQ_STATUS = '00' AND months_gap = 1 THEN 'episode starts' 
ELSE 'Nothing imp'
END as episode_flag
FROM (
SELECT TOP(100000) LOAN_ID, ACT_PERIOD, ORIG_DATE, FIRST_PAY, ORIG_RATE, CURR_RATE, ORIG_UPB, CURRENT_UPB, LOAN_AGE ,HOMEREADY_PROGRAM_INDICATOR,DLQ_STATUS,
CASE 
WHEN DLQ_STATUS = '00' THEN 'Current'
WHEN DLQ_STATUS = 'XX' OR DLQ_STATUS = '' OR DLQ_STATUS IS NULL THEN 'Unknown'
ELSE 'Delinquent'
END AS Classifying_delinquent,
LAG(DLQ_STATUS) OVER (PARTITION BY LOAN_ID ORDER BY ACT_PERIOD ASC) AS previous_DLQ_STATUS,
DATEDIFF(MONTH, LAG(ACT_PERIOD) OVER (PARTITION BY LOAN_ID ORDER BY ACT_PERIOD ASC), ACT_PERIOD) AS months_gap
FROM p1_2018q1_clean ) AS new_sub


-- STEP 4:Discarding rows where 1st row is only DLY , as it means we cant  see the actual start of it


Select LOAN_ID , DLQ_STATUS 
FROM (
SELECT  LOAN_ID , DLQ_STATUS ,
ROW_NUMBER() OVER (PARTITION BY LOAN_ID ORDER BY ACT_PERIOD ASC) as rn
FROM p1_2018q1_clean) AS sub_q
WHERE rn =1 AND DLQ_STATUS NOT IN ('00', 'XX')