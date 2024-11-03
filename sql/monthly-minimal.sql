SELECT vote,
    title,
    developer,
    released
FROM "Monthly"
WHERE finished BETWEEN '2024-10-01' AND '2024-10-31' -- finished this month
    OR (
        finished IS NULL
        AND NOT started > '2024-10-31' -- WIP/Dropped/Stalled
        AND NOT (
            started < '2024-10-01' -- excluded earlier VNs
            AND NOT labels = 'Playing'
        )
    )
ORDER BY "vote" DESC,
    "released" DESC,
    -- the newer, the better...
    "title" ASC;