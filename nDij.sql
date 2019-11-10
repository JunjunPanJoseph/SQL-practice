with recursive degrees as (
        select o.id as oid, o.name as oname, a.aid as nid, n.name as nname, 1 as dist, Movie.title as title
        from Actor o, Actor n, Movie, (
                Acting a1
                inner join 
                (select movie_id as mid, actor_id as aid from Acting) a2 
                on a1.movie_id = a2.mid  
            ) a
        where lower(o.name) = lower('emma stone')
                and o.id = a.actor_id
                and n.id = a.aid
                and Movie.id = a.mid
                and o.id != a.aid
    union ALL
        select a.nid as oid, a.nname as oname, a.aid as nid,Actor.name as nname, a.dist + 1 as dist, Movie.title as title
        from Actor, Movie ,(
                (Acting a1 
                inner join 
                (select movie_id as mid, actor_id as aid from Acting) a2 
                on a1.movie_id = a2.mid ) at
            inner join 
                degrees
            on 
                degrees.nid = at.actor_id
                and
                degrees.dist < 3
                and at.aid != degrees.nid
            ) a
        where Actor.id = a.aid
                and Movie.id = a.mid
)
select distinct(degrees.*)
from 
    degrees, (
    select nname as minName,  min(dist) as dist 
    from degrees
    group by  nname
    ) t
where degrees.nname = t.minName
            and degrees.dist = t.dist
order by degrees.dist
;
