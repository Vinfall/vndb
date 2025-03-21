SELECT
    to_char(lv.date, 'YYYY-MM-DD') AS "date",
    vn.title,
    -- length in minutes
    lv.length,
    CASE
        WHEN lv.speed = 0 THEN 'Slow'
        WHEN lv.speed = 1 THEN 'Normal'
        WHEN lv.speed = 2 THEN 'Fast'
        WHEN lv.speed IS null THEN ''
    END AS "speed",
    array_to_string(lv.rid, ',') AS rid,
    lv.notes
FROM vndb.vn_length_votes AS lv
INNER JOIN vndb.vn AS vn ON lv.vid = vn.id
WHERE lv.uid = { UID } -- Change to your User ID -- noqa
ORDER BY
    lv.date DESC;