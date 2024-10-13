select vn.title,
    vn.alias,
    string_agg(distinct p.name, ', ') as "Developer",
    round(CAST(vote AS numeric) / 10, 1) as "Vote",
    u.vid,
    u.started,
    u.finished,
    case
        when min(released) % 100 = 99 then min(released) - 98
        else min(released)
    end as "Release Date",
    -- deal with 99999901 stuff
    c_votecount as "RatingDP",
    round(CAST(c_rating AS numeric) / 100, 2) as "Rating",
    CASE
        WHEN labels @> '{1}' THEN 'Playing'
        WHEN labels @> '{2}' THEN 'Finished'
        WHEN labels @> '{3}' THEN 'Stalled'
        WHEN labels @> '{4}' THEN 'Dropped'
        WHEN labels @> '{5}' THEN 'Wishlist'
    END as "Labels"
from vndb.ulist_vns u
    join vndb.vn vn on u.vid = vn.id
    left join releases_vn rvn on rvn.vid = vn.id
    left join releases r on r.id = rvn.id
    and rtype <> 'trial'
    left join releases_producers rp on r.id = rp.id
    left join producers p on rp.pid = p.id
WHERE u.uid = { UID } -- change to your User ID
    -- and vote is not null  -- voted VN only
    AND NOT labels @> '{5}' -- exclude wishlist items
group by vn.title,
    vn.alias,
    vote,
    u.vid,
    u.started,
    u.finished,
    c_votecount,
    c_rating,
    labels