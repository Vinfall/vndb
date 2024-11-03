SELECT vote,
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