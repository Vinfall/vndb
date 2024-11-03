SELECT round(CAST(vote AS numeric) / 10, 1) AS "vote",
    round(CAST(c_rating AS numeric) / 100, 2) AS "rating",
    c_votecount AS "ratingDP",
    CASE
        WHEN labels @> '{1}' THEN 'Playing' -- possible to have multiple labels
        WHEN labels @> '{2}' THEN 'Finished'
        WHEN labels @> '{3}' THEN 'Stalled'
        WHEN labels @> '{4}' THEN 'Dropped'
        WHEN labels @> '{5}' THEN 'Wishlist'
    END AS "labels",
    vn.title,
    string_agg(distinct p.name, ', ') AS "developer",
    u.started,
    u.finished,
    CASE
        WHEN min(released) % 100 = 99 THEN TO_CHAR(
            TO_DATE((min(released) - 98)::text, 'YYYYMMDD'),
            'YYYY-MM-DD'
        ) -- deal with 99999901 stuff
        ELSE TO_CHAR(
            TO_DATE(min(released)::text, 'YYYYMMDD'),
            'YYYY-MM-DD'
        ) -- convert to ISO date
    END AS "released"
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
    AND (
        u.finished BETWEEN '2024-10-01' AND '2024-10-31' -- finished this month
        OR (
            u.finished IS NULL
            AND NOT u.started > '2024-10-31' -- WIP/Dropped/Stalled
            AND NOT (
                u.started < '2024-10-01' -- excluded earlier VNs
                AND NOT labels @> '{1}'
            )
        )
    )
GROUP BY vn.title,
    vote,
    u.started,
    u.finished,
    c_votecount,
    c_rating,
    labels
ORDER BY labels DESC,
    -- finished > dropped
    u.finished DESC,
    u.started DESC