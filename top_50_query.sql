WITH ranked AS (
    SELECT 
        Ticker, Price, Daily_Vol,
        PERCENT_RANK() OVER (ORDER BY `1_month`) AS p1,
        PERCENT_RANK() OVER (ORDER BY `3_month`) AS p3,
        PERCENT_RANK() OVER (ORDER BY `6_month`) AS p6,
        PERCENT_RANK() OVER (ORDER BY `12_month`) AS p12
    FROM sp_500_hqm
),
top50 AS (
    SELECT *, (p1 + p3 + p6 + p12) / 4.0 AS HQM_Score,
           1.0 / Daily_Vol AS inv_vol
    FROM ranked
    ORDER BY HQM_Score DESC
    LIMIT 50
)
SELECT 
    Ticker, Price,
    ROUND(HQM_Score * 100, 2) AS HQM_Score,
    ROUND((inv_vol / SUM(inv_vol) OVER ()) * 100, 2) AS Weight_Pct,
    FLOOR((inv_vol / SUM(inv_vol) OVER ()) * 100000 / Price) AS Shares_to_Buy
FROM top50
ORDER BY HQM_Score DESC;
