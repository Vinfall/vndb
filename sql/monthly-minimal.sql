SELECT vote,
    title,
    developer,
    released
FROM "Monthly"
ORDER BY "vote" DESC,
    "released" DESC,
    -- the newer, the better...
    "title" ASC;