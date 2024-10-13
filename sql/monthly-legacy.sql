SELECT *
FROM "VNDB"
WHERE "Finish date" BETWEEN '2024-09-01' AND '2024-09-30' -- would get replaced in monthly-legacy.py
    OR (
        "Finish date" IS NULL
        AND NOT "Start date" > '2024-09-01'
        AND NOT (
            "Start date" < '2024-09-01'
            AND NOT Labels = 'Playing'
        )
    )
ORDER BY "Start date" DESC