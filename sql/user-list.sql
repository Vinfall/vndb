SELECT vn.title,
    vn.alias,
    string_agg(distinct p.name, ', ') AS "Developer",
    round(CAST(vote AS numeric) / 10, 1) AS "Vote",
    u.vid,
    u.started,
    u.finished,
    CASE
        min(released) %100
        WHEN 99 THEN min(released) -98
        ELSE min(released)
    END AS "Released",
    -- deal with 99999901 stuff
    c_votecount AS "RatingDP",
    round(CAST(c_rating AS numeric) / 100, 2) AS "Rating",
    CASE
        WHEN labels @> '{1}' THEN 'Playing' -- possible to have multiple labels
        WHEN labels @> '{2}' THEN 'Finished'
        WHEN labels @> '{3}' THEN 'Stalled'
        WHEN labels @> '{4}' THEN 'Dropped'
        WHEN labels @> '{5}' THEN 'Wishlist'
    END AS "Labels"
FROM vndb.ulist_vns u
    JOIN vndb.vn vn ON u.vid = vn.id
    LEFT JOIN releases_vn rvn ON rvn.vid = vn.id
    LEFT JOIN releases r ON r.id = rvn.id
    AND rtype <> 'trial'
    LEFT JOIN releases_producers rp ON r.id = rp.id
    LEFT JOIN producers p ON rp.pid = p.id
WHERE u.uid = { UID } -- change to your User ID
    -- and vote is not null  -- voted VN only
    AND NOT labels @> '{5}' -- exclude wishlist
GROUP BY vn.title,
    vn.alias,
    vote,
    u.vid,
    u.started,
    u.finished,
    c_votecount,
    c_rating,
    labels