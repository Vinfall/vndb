SELECT
    CASE
        WHEN vote LIKE '%.0' THEN cast(replace(vote, '.0', '') AS integer)
        ELSE cast(vote AS real)
    END AS vote,
    title,
    developer,
    released
FROM (
    SELECT
        *,
        row_number() OVER (
            ORDER BY
                labels DESC,
                finished DESC,
                started DESC
        ) AS original_order
    FROM "Monthly"
) AS RankedResults
ORDER BY
    vote DESC,
    original_order ASC;