SELECT
    Vote,
    Title,
    Developer,
    "Release date"
FROM "VNDB"
WHERE
    "Finish date" BETWEEN '2024-09-01' AND '2024-09-30' -- would get replaced in monthly-legacy.py
    OR (
        "Finish date" IS null
        AND NOT "Start date" > '2024-09-01'
        AND NOT (
            "Start date" < '2024-09-01'
            AND NOT Labels = 'Playing'
        )
    )
ORDER BY
    "Vote" DESC,
    "Rating" DESC,
    "LengthDP" DESC;