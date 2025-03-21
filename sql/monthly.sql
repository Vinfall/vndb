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
    string_agg(DISTINCT p.name, ', ') AS "developer",
    u.started,
    u.finished,
    CASE
        WHEN min(released) IS null THEN '2099-12-31'
        WHEN
            length(cast(min(released) AS text)) = 8
            THEN
                substr(cast(min(released) AS text), 1, 4)
                || '-'
                || substr(cast(min(released) AS text), 5, 2)
                || '-'
                || substr(cast(min(released) AS text), 7, 2)
        ELSE '2099-12-31' -- dumb ISO date conversion
    END AS "released"
FROM vndb.ulist_vns AS u
INNER JOIN vndb.vn AS vn ON u.vid = vn.id
LEFT JOIN releases_vn AS rvn ON vn.id = rvn.vid
LEFT JOIN releases AS r
    ON
        rvn.id = r.id
        AND rtype != 'trial'
LEFT JOIN releases_producers AS rp ON r.id = rp.id
LEFT JOIN producers AS p ON rp.pid = p.id
WHERE
    u.uid = '{ UID }' -- change to your User ID
    -- and vote is not null  -- voted VN only
    AND NOT labels @> '{5}' -- exclude wishlist -- noqa
    AND (
        u.finished BETWEEN '2025-01-01' AND '2025-01-31' -- finished this month
        OR (
            u.finished IS null
            AND NOT u.started > '2025-01-31' -- WIP/Dropped/Stalled
            AND NOT (
                u.started < '2025-01-01' -- excluded earlier VNs
                AND NOT labels @> '{1}'
            )
        )
    )
GROUP BY
    vn.title,
    vote,
    u.started,
    u.finished,
    c_votecount,
    c_rating,
    labels
ORDER BY
    labels DESC,
    -- finished > dropped
    u.finished DESC,
    u.started DESC,
    vote DESC,
    rating DESC