ALTER TABLE Tima_CRM_final_cleaned
ALTER COLUMN InitialLoanAmountRequested DECIMAL(18,2);

ALTER TABLE Tima_CRM_final_cleaned
ALTER COLUMN DisbursedLoanAmount DECIMAL(18,2);

--- Tính tổng số tiền đăng ký vay ban đầu (SoTienDKVayBanDau) theo từng loại sản phẩm tín dụng (ProductCreditName) 
--và so sánh với tổng tiền giải ngân (TienGiaiNgan).
SELECT 
    CreditProductName,

    SUM(InitialLoanAmountRequested) AS Total_initial_loan,

    SUM(DisbursedLoanAmount) AS Total_disbursed,

    SUM(InitialLoanAmountRequested)
    - SUM(DisbursedLoanAmount) AS Differences,

    ROUND(
        SUM(DisbursedLoanAmount) * 100.0
        /
        NULLIF(SUM(InitialLoanAmountRequested), 0),
        2
    ) AS Percent_disbursed

FROM Tima_CRM_final_cleaned

GROUP BY CreditProductName

ORDER BY  SUM(InitialLoanAmountRequested)
    - SUM(DisbursedLoanAmount) DESC;
   
-- Hiển thị danh sách các khoản vay có tỷ lệ giải ngân thấp hơn 50% 
---(SoTienGiaiNgan / SoTienDKVayBanDau < 0.5) và phân tích theo thành phố (CityName).
SELECT
    LoanID,
    FullName,
    CityName,
    CreditProductName,
    InitialLoanAmountRequested,
    DisbursedLoanAmount,

    CAST(
        ROUND(
            DisbursedLoanAmount * 100.0
            / NULLIF(InitialLoanAmountRequested, 0),
            2
        )
    AS DECIMAL(10,2)) AS Disbursement_percent

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE 
    DisbursedLoanAmount * 1.0
    / NULLIF(InitialLoanAmountRequested, 0) < 0.5

ORDER BY Disbursement_percent ASC;
--Phân tích theo city 
SELECT
    CityName,

    COUNT(*) AS Loan_count,

    SUM(InitialLoanAmountRequested) AS Total_initial_loan,

    SUM(DisbursedLoanAmount) AS Total_disbursed,

    SUM(InitialLoanAmountRequested)
    - SUM(DisbursedLoanAmount) AS Differences,

    CAST(
        ROUND(
            AVG(
                DisbursedLoanAmount * 100.0
                / NULLIF(InitialLoanAmountRequested, 0)
            ),
            2
        )
    AS DECIMAL(10,2)) AS Avg_disbursement_percent

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE 
    DisbursedLoanAmount * 1.0
    / NULLIF(InitialLoanAmountRequested, 0) < 0.5

GROUP BY CityName

ORDER BY Loan_count DESC;

---Tính mức chênh lệch giữa số tiền đăng ký vay ban đầu và số tiền còn lại (SoTienConLai) cho mỗi khách hàng, 
---và phân loại theo độ tuổi khách hàng (Age = Thời gian đã sống).

SELECT
    CASE
        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) < 25 
            THEN 'Under 25'

        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) BETWEEN 25 AND 35 
            THEN '25-35'

        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) BETWEEN 36 AND 45 
            THEN '36-45'

        ELSE 'Above 45'
    END AS Age_group,

    COUNT(*) AS Customer_count,

    CAST(
    AVG(
        InitialLoanAmountRequested
        - [RemainingPrincipalAmount]
    )
AS DECIMAL(18,2)) AS Avg_difference,

    CAST(
    SUM(
        InitialLoanAmountRequested
        - [RemainingPrincipalAmount]
    )
AS DECIMAL(18,2)) AS Total_difference

FROM Tima_CRM_final_cleaned

GROUP BY
    CASE
        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) < 25 
            THEN 'Under 25'

        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) BETWEEN 25 AND 35 
            THEN '25-35'

        WHEN DATEDIFF(YEAR, Birthday, GETDATE()) BETWEEN 36 AND 45 
            THEN '36-45'

        ELSE 'Above 45'
    END

ORDER BY Avg_difference DESC;

-- Phân tích các khoản vay có mức giải ngân cao nhất so với số tiền vay ban đầu, 
---theo từng quận (DistrictName) và giới tính (Gender) 0 là nam, 1 là nữ .

SELECT
    DistrictName,
    Gender,

    COUNT(*) AS Loan_count,

    SUM(InitialLoanAmountRequested) AS Total_initial_loan,

    SUM(DisbursedLoanAmount) AS Total_disbursed,

    CAST(
        ROUND(
            SUM(DisbursedLoanAmount) * 100.0
            /
            NULLIF(SUM(InitialLoanAmountRequested), 0),
            2
        )
    AS DECIMAL(10,2)) AS Disbursement_percent

FROM Tima_CRM_final_cleaned

GROUP BY
    DistrictName,
    Gender
HAVING COUNT(*) >= 5
ORDER BY Disbursement_percent DESC;

---- Câu 5 Tính tỷ lệ hoàn thành giải ngân (Số tiền giải ngân/Số tiền đăng ký vay) cho các khoản vay 
----và xác định các yếu tố ảnh hưởng (ví dụ: nghề nghiệp).

SELECT
    [JobName],

    SUM(InitialLoanAmountRequested) AS Total_initial_loan,

    SUM(DisbursedLoanAmount) AS Total_disbursed,

    COUNT(*) AS Loan_count,

    CAST(
        ROUND(
            AVG(
                DisbursedLoanAmount * 100.0
                /
                NULLIF(InitialLoanAmountRequested, 0)
            ),
            2
        )
    AS DECIMAL(10,2)) AS Avg_disbursement_percent

FROM Tima_CRM_final_cleaned

GROUP BY [JobName]

HAVING COUNT(*) >= 5

ORDER BY Avg_disbursement_percent DESC;

--Theo residence type

SELECT
    [ResidenceType],

    SUM(InitialLoanAmountRequested) AS Total_initial_loan,

    SUM(DisbursedLoanAmount) AS Total_disbursed,

    COUNT(*) AS Loan_count,

    CAST(
        ROUND(
            AVG(
                DisbursedLoanAmount * 100.0
                /
                NULLIF(InitialLoanAmountRequested, 0)
            ),
            2
        )
    AS DECIMAL(10,2)) AS Avg_disbursement_percent

FROM Tima_CRM_final_cleaned

GROUP BY [ResidenceType]

HAVING COUNT(*) >= 5

ORDER BY Avg_disbursement_percent DESC;


--- Xác định tỷ lệ phần trăm các khoản vay đã trả hết (Trạng thái) 
--theo các vùng địa lý khác nhau (CityName, DistrictName).

SELECT
    CityName, [DistrictName],
    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN Status = N'Kết Thúc' THEN 1
            ELSE 0
        END
    ) AS paid_off_loans,

    ROUND(
        CAST(
            100.0 * SUM(
                CASE
                    WHEN Status = N'Kết Thúc' THEN 1
                    ELSE 0
                END
            ) / COUNT(*)
        AS DECIMAL(10,2)),
    2) AS paid_off_percentage

FROM Tima_CRM_final_cleaned

GROUP BY
    CityName,
[DistrictName]
HAVING COUNT(*) > 5
ORDER BY paid_off_percentage DESC;

--Phân tích trạng thái khoản vay của khách hàng theo nhóm thu nhập (Salary) và loại công việc (JobName)

WITH salary_status AS (
    SELECT
        CASE
            WHEN Salary < 5000000 THEN N'Dưới 5 triệu'
            WHEN Salary >= 5000000 AND Salary < 10000000 THEN N'5 - 10 triệu'
            WHEN Salary >= 10000000 AND Salary < 20000000 THEN N'10 - 20 triệu'
            ELSE N'Trên 20 triệu'
        END AS salary_group,

        CASE
            WHEN Salary < 5000000 THEN 1
            WHEN Salary >= 5000000 AND Salary < 10000000 THEN 2
            WHEN Salary >= 10000000 AND Salary < 20000000 THEN 3
            ELSE 4
        END AS salary_order,

        Status
    FROM Tima_CRM_final_cleaned
    WHERE Salary IS NOT NULL
)

SELECT
    salary_group,
    Status,
    COUNT(*) AS total_loans,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (
            PARTITION BY salary_group
        ),
        2
    ) AS status_percentage

FROM salary_status

GROUP BY
    salary_group,
    salary_order,
    Status

HAVING COUNT(*) > 5

ORDER BY
    salary_order,
    CASE
        WHEN Status = N'Kết Thúc' THEN 1
        WHEN Status = N'Đang Vay' THEN 2
        WHEN Status = N'Nợ Xấu' THEN 3
        ELSE 4
    END;

    ---Tính theo jobname------------------------------------------------------------

   WITH job_status AS (
    SELECT
        JobName,
        Status,
        COUNT(*) AS total_loans
    FROM Tima_CRM_final_cleaned
    WHERE JobName IS NOT NULL
    GROUP BY
        JobName,
        Status
),

job_total AS (
    SELECT
        JobName,
        SUM(total_loans) AS total_job_loans
    FROM job_status
    GROUP BY JobName
)

SELECT
    js.JobName,
    js.Status,
    js.total_loans,

    ROUND(
        CAST(
            100.0 * js.total_loans / jt.total_job_loans
        AS DECIMAL(10,2)),
    2) AS status_percentage

FROM job_status js
JOIN job_total jt
    ON js.JobName = jt.JobName

WHERE jt.total_job_loans > 20

ORDER BY
    jt.total_job_loans DESC,
    js.JobName,
    CASE
        WHEN js.Status = N'Kết Thúc' THEN 1
        WHEN js.Status = N'Đang Vay' THEN 2
        WHEN js.Status = N'Nợ Xấu' THEN 3
        ELSE 4
    END;

-------- Hình thức trả lãi nào có chất lượng khoản vay tốt hơn hoặc rủi ro hơn?

SELECT
    InterestPaymentType,

    COUNT(*) AS total_loans,

    SUM(
        CASE
            WHEN Status = N'Nợ Xấu' THEN 1
            ELSE 0
        END
    ) AS bad_debt_loans,

    ROUND(
        CAST(
            100.0 * SUM(
                CASE
                    WHEN Status = N'Nợ Xấu' THEN 1
                    ELSE 0
                END
            ) / COUNT(*)
        AS DECIMAL(10,2)),
    2) AS bad_debt_percentage

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE InterestPaymentType IS NOT NULL

GROUP BY
    InterestPaymentType

HAVING COUNT(*) >= 30

ORDER BY
    bad_debt_percentage DESC;

SELECT SUM(CAST([Salary] AS BIGINT))
FROM [dbo].[Tima_CRM_final_cleaned]



   -----Phân tích sự phân bố điểm tín dụng (TS_CREDIT_SCORE_V2) của khách hàng 
-----và so sánh theo nhóm thu nhập (Salary).

SELECT
    CASE
        WHEN Salary < 5000000 THEN N'Dưới 5 triệu'
        WHEN Salary >= 5000000 AND Salary < 10000000 THEN N'5 - 10 triệu'
        WHEN Salary >= 10000000 AND Salary < 20000000 THEN N'10 - 20 triệu'
        ELSE N'Trên 20 triệu'
    END AS salary_group,

    COUNT(*) AS total_customers,

    ROUND(AVG(TSCreditScoreV2), 2) AS avg_credit_score,

    MIN(TSCreditScoreV2) AS min_credit_score,

    MAX(TSCreditScoreV2) AS max_credit_score,

    ROUND(STDEV(TSCreditScoreV2), 2) AS stddev_credit_score

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE Salary IS NOT NULL
    AND TSCreditScoreV2 IS NOT NULL

GROUP BY
    CASE
        WHEN Salary < 5000000 THEN N'Dưới 5 triệu'
        WHEN Salary >= 5000000 AND Salary < 10000000 THEN N'5 - 10 triệu'
        WHEN Salary >= 10000000 AND Salary < 20000000 THEN N'10 - 20 triệu'
        ELSE N'Trên 20 triệu'
    END

HAVING COUNT(*) >= 30

ORDER BY
    CASE
        WHEN MIN(Salary) < 5000000 THEN 1
        WHEN MIN(Salary) >= 5000000 AND MIN(Salary) < 10000000 THEN 2
        WHEN MIN(Salary) >= 10000000 AND MIN(Salary) < 20000000 THEN 3
        ELSE 4
    END;

    ----- Hiển thị các khách hàng có điểm tín dụng (TS_CREDIT_SCORE_V2) dưới 500 
    ----- và phân tích xu hướng quá hạn của họ.

    SELECT
    CASE
        WHEN HasLatePayment = 1 THEN N'Từng quá hạn'
        ELSE N'Chưa quá hạn'
    END AS late_payment_status,

    COUNT(*) AS total_customers,

    ROUND(
        CAST(
            100.0 * COUNT(*) /
            SUM(COUNT(*)) OVER ()
        AS DECIMAL(10,2)),
    2) AS percentage

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE TSCreditScoreV2 < 500

GROUP BY
    CASE
        WHEN HasLatePayment = 1 THEN N'Từng quá hạn'
        ELSE N'Chưa quá hạn'
    END;

    ----- Xác định các yếu tố ảnh hưởng đến điểm tín dụng của khách hàng 
    -----(Gender, CityName, Salary) qua một mô hình phân tích đa biến.

    SELECT
    Gender,
    CityName,

    CASE
        WHEN Salary < 5000000 THEN N'Dưới 5 triệu'
        WHEN Salary < 10000000 THEN N'5 - 10 triệu'
        WHEN Salary < 20000000 THEN N'10 - 20 triệu'
        ELSE N'Trên 20 triệu'
    END AS salary_group,

    COUNT(*) AS total_customers,

    ROUND(AVG(TSCreditScoreV2), 2) AS avg_credit_score

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE TSCreditScoreV2 IS NOT NULL

GROUP BY
    Gender,
    CityName,

    CASE
        WHEN Salary < 5000000 THEN N'Dưới 5 triệu'
        WHEN Salary < 10000000 THEN N'5 - 10 triệu'
        WHEN Salary < 20000000 THEN N'10 - 20 triệu'
        ELSE N'Trên 20 triệu'
    END

HAVING COUNT(*) >= 5

ORDER BY
    avg_credit_score DESC;

    --------Tính tỷ lệ các khách hàng có điểm tín dụng dưới 600 và so sánh với tỷ lệ nợ xấu (HasBadDebt).

    SELECT
    CASE
        WHEN TSCreditScoreV2 < 600 THEN N'Score dưới 600'
        ELSE N'Score từ 600 trở lên'
    END AS credit_score_group,

    COUNT(*) AS total_customers,

    SUM(
        CASE
            WHEN HasBadDebt = 1 THEN 1
            ELSE 0
        END
    ) AS bad_debt_customers,

    ROUND(
        CAST(
            100.0 * SUM(
                CASE
                    WHEN HasBadDebt = 1 THEN 1
                    ELSE 0
                END
            ) / COUNT(*)
        AS DECIMAL(10,2)),
    2) AS bad_debt_percentage

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE TSCreditScoreV2 IS NOT NULL
    AND HasBadDebt IS NOT NULL

GROUP BY
    CASE
        WHEN TSCreditScoreV2 < 600 THEN N'Score dưới 600'
        ELSE N'Score từ 600 trở lên'
    END

ORDER BY
    credit_score_group;

    ------- Hiển thị phân bố điểm tín dụng (TS_CREDIT_SCORE_V2) 
    -------và phân tích theo trạng thái khoản vay (Trạng thái) và sản phẩm tín dụng.

    SELECT
    CreditProductName,
    Status,

    COUNT(*) AS total_loans,

    ROUND(AVG(TSCreditScoreV2), 2) AS avg_credit_score,

    MIN(TSCreditScoreV2) AS min_credit_score,

    MAX(TSCreditScoreV2) AS max_credit_score,

    ROUND(STDEV(TSCreditScoreV2), 2) AS stddev_credit_score

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE TSCreditScoreV2 IS NOT NULL
    AND CreditProductName IS NOT NULL
    AND Status IS NOT NULL

GROUP BY
    CreditProductName,
    Status

HAVING COUNT(*) >= 20

ORDER BY
    CreditProductName,
    CASE
        WHEN Status = N'Kết Thúc' THEN 1
        WHEN Status = N'Đang Vay' THEN 2
        WHEN Status = N'Nợ Xấu' THEN 3
        ELSE 4
    END; 



----- Truy vấn theo thông tin khách hàng
----- Phân tích độ tuổi trung bình của khách hàng vay tiền 
-----theo thành phố (CityName) và khu vực (DistrictName).

SELECT
    CityName,
    DistrictName,

    COUNT(*) AS total_customers,

    ROUND(
        AVG(
            DATEDIFF(YEAR, Birthday, GETDATE())
        ),
    2) AS avg_age,

    MIN(
        DATEDIFF(YEAR, Birthday, GETDATE())
    ) AS min_age,

    MAX(
        DATEDIFF(YEAR, Birthday, GETDATE())
    ) AS max_age

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE Birthday IS NOT NULL
    AND CityName IS NOT NULL
    AND DistrictName IS NOT NULL

GROUP BY
    CityName,
    DistrictName

HAVING COUNT(*) >= 10

ORDER BY
    avg_age DESC;

    ------Tính số lượng khách hàng theo từng nhóm giới tính (Gender) 
    ------và phân tích theo tỷ lệ nợ xấu (HasBadDebt)

   WITH customer_bad_debt AS (
    SELECT
        ID,
        Gender,
        MAX(
            CASE 
                WHEN HasBadDebt = 1 THEN 1
                ELSE 0
            END
        ) AS is_bad_debt
    FROM [dbo].[Tima_CRM_final_cleaned]
    GROUP BY ID, Gender
)

SELECT
    Gender,

    COUNT(*) AS total_customers,

    SUM(is_bad_debt) AS bad_debt_customers,

    CAST(
        ROUND(
            (SUM(is_bad_debt) * 100.0) / COUNT(*),
            2
        )
        AS DECIMAL(5,2)
    ) AS bad_debt_rate_percent

FROM customer_bad_debt

GROUP BY Gender

ORDER BY bad_debt_rate_percent DESC;

------ Phân tích mức độ ảnh hưởng của độ tuổi khách hàng (Thời gian đã sống) 
------đến quyết định vay tiền, xác định các nhóm khách hàng có nguy cơ nợ xấu cao.

WITH customer_age AS (
    SELECT
        ID,
        Birthday,

        DATEDIFF (YEAR, Birthday, GETDATE()) AS age,

        HasBadDebt,
        DisbursedLoanAmount

    FROM [dbo].[Tima_CRM_final_cleaned]
    WHERE Birthday IS NOT NULL
),

age_group AS (
    SELECT
        *,

        CASE
            WHEN age < 25 THEN 'Under 25'
            WHEN age BETWEEN 25 AND 34 THEN '25-34'
            WHEN age BETWEEN 35 AND 44 THEN '35-44'
            WHEN age BETWEEN 45 AND 54 THEN '45-54'
            ELSE '55+'
        END AS age_range

    FROM customer_age
)

SELECT
    age_range,

    COUNT(DISTINCT ID) AS total_customers,

    SUM(
        CASE
            WHEN HasBadDebt = 1 THEN 1
            ELSE 0
        END
    ) AS bad_debt_customers,

    CAST(
        ROUND(
            100.0 * SUM(
                CASE
                    WHEN HasBadDebt = 1 THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            2
        )
        AS DECIMAL(5,2)
    ) AS bad_debt_rate_percent,

    CAST(
    ROUND(AVG(DisbursedLoanAmount),0)
    AS DECIMAL(18,0)
) AS avg_loan_amount

FROM age_group

GROUP BY age_range

ORDER BY bad_debt_rate_percent DESC;



-----TRUY VẤN THEO ĐỊA CHỈ 
-----Phân tích các khách hàng sống tại các quận có tỷ lệ nợ xấu cao,
-----và so sánh với các yếu tố như thu nhập, nghề nghiệp.

SELECT
    DistrictName,

    [JobName],

    COUNT(DISTINCT ID) AS total_customers,

    CAST(
        AVG(Salary)
        AS DECIMAL(18,0)
    ) AS avg_salary,

    CAST(
        AVG(DisbursedLoanAmount)
        AS DECIMAL(18,0)
    ) AS avg_loan_amount,

    SUM(
        CASE
            WHEN HasBadDebt = 1 THEN 1
            ELSE 0
        END
    ) AS bad_debt_customers,

    CAST(
        ROUND(
            100.0 * SUM(
                CASE
                    WHEN HasBadDebt = 1 THEN 1
                    ELSE 0
                END
            ) / COUNT(*),
            2
        ) AS DECIMAL(5,2)
    ) AS bad_debt_rate_percent

FROM [dbo].[Tima_CRM_final_cleaned]

WHERE DistrictName IS NOT NULL
  AND  [JobName] IS NOT NULL
  AND Salary IS NOT NULL

GROUP BY
    DistrictName,
    [JobName]

HAVING COUNT(*) >= 5

ORDER BY bad_debt_rate_percent DESC,
         avg_salary ASC;

