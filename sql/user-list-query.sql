select vn.title,
    vn.alias,
    string_agg(distinct p.name, ', ') as "Developer",
    round(CAST(vote AS numeric) / 10, 1) as "Vote",
    u.vid,
    u.started,
    u.finished,
    round(avg(lv.length) / 60, 2) as "Length",
    case
        when min(released) % 100 = 99 then min(released) - 98
        else min(released)
    end as "Release Date",
    -- Deal with 99999901 stuff
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
    left join vn_length_votes lv on vn.id = lv.vid
    and speed = 1
    left join releases_producers rp on r.id = rp.id
    left join producers p on rp.pid = p.id
WHERE u.uid = { UID } --Change to your User ID
    -- and vote is not null  -- Add this if you want to only Voted VN
    AND NOT labels @> '{5}' -- Exclude wishlist items (label value == {5})
group by vn.title,
    vn.alias,
    vote,
    u.vid,
    u.vid,
    u.started,
    u.finished,
    c_votecount,
    c_rating,
    labels