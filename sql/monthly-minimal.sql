SELECT CASE
        WHEN vote LIKE '%.0' THEN CAST(REPLACE(vote, '.0', '') AS INTEGER)
        ELSE CAST(vote AS REAL)
    END AS vote,
    title,
    developer,
    released
FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                ORDER BY labels DESC,
                    finished DESC,
                    started DESC
            ) AS original_order
        FROM "Monthly"
    ) AS RankedResults
ORDER BY vote DESC,
    original_order;