SELECT TO_CHAR(lv.date, 'YYYY-MM-DD') AS date,
    vn.title,
    -- length in minutes
    lv.length,
    CASE
        WHEN lv.speed = 0 THEN 'Slow'
        WHEN lv.speed = 1 THEN 'Normal'
        WHEN lv.speed = 2 THEN 'Fast'
        WHEN lv.speed is NULL THEN '-'
    END as "speed",
    ARRAY_TO_STRING(lv.rid, ',') AS rid,
    lv.notes
FROM vndb.vn_length_votes lv
    JOIN vndb.vn vn ON lv.vid = vn.id
WHERE lv.uid = { UID } --Change to your User ID
ORDER BY lv.date DESC;