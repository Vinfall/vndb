SELECT
    round(cast(vote AS numeric) / 10, 1) AS "vote",
    round(cast(c_rating AS numeric) / 100, 2) AS "rating",
    c_votecount AS "ratingDP",
    CASE -- noqa
        WHEN labels @> '{1}' THEN 'Playing' -- possible to have multiple labels
        WHEN labels @> '{2}' THEN 'Finished'
        WHEN labels @> '{3}' THEN 'Stalled'
        WHEN labels @> '{4}' THEN 'Dropped'
        WHEN labels @> '{5}' THEN 'Wishlist'
    END AS "labels",
    vn.title,
    string_agg(DISTINCT p.name, ',') AS "developer",
    u.started,
    u.finished,
    CASE
    min(released) % 100
        WHEN 99 THEN min(released) - 98
        ELSE min(released)
    END AS "released" -- deal with 99999901 stuff
FROM vndb.ulist_vns AS u
JOIN vndb.vn AS vn ON u.vid = vn.id
LEFT JOIN releases_vn AS rvn ON rvn.vid = vn.id
LEFT JOIN releases AS r
    ON
        r.id = rvn.id
        AND rtype != 'trial'
LEFT JOIN releases_producers AS rp ON r.id = rp.id
LEFT JOIN producers AS p ON rp.pid = p.id
WHERE
    u.uid = { UID } -- change to your User ID -- noqa
    -- and vote is not null  -- voted VN only
    AND NOT labels @> '{5}' -- exclude wishlist -- noqa
GROUP BY
    vn.title,
    vote,
    u.vid,
    u.started,
    u.finished,
    c_votecount,
    c_rating,
    labels
ORDER BY
    labels DESC,
    -- finished > dropped
    u.finished DESC,
    u.started DESC