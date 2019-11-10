with A0 as (
select Actor.id as actor_id, Acting.movie_id as movie_id 
from Actor, Acting 
where lower(Actor.name) = lower('chris evans')
    and Actor.id = Acting.actor_id
)
select A1.actor_id, A2.movie_id, A2.actor_id, A3.movie_id, A3.actor_id
from 
(
    (
        A0 inner join Acting A1
        on A0.movie_id = A1.movie_id
    ) 
    inner join 
    (
        Acting A1_2 inner join Acting A2 
        on A1_2.movie_id = A2.movie_id

    )
    on A1.actor_id = A1_2.actor_id
)
inner join
(
        Acting A2_2 inner join Acting A3 
        on A2_2.movie_id = A3.movie_id
) 
on A2.actor_id = A2_2.actor_id
where A1.actor_id != A0.actor_id
        and A1_2.actor_id != A0.actor_id
        and A2.actor_id != A0.actor_id
        and A2.actor_id != A1.actor_id
        and A2_2.actor_id != A0.actor_id
        and A2_2.actor_id != A1.actor_id
        and A3.actor_id != A0.actor_id
        and A3.actor_id != A1.actor_id
        and A3.actor_id != A2.actor_id
;


with recursive degrees as (
        select Actor.id as id, Actor.name as name, 0 as dist
        from Actor
        where lower(Actor.name) = lower('emma stone')
    union ALL

    select distinct a.aid as id,Actor.name as name, a.dist + 1 as dist
    from Actor, (
            (Acting a1 
            inner join 
            (select movie_id as mid, actor_id as aid from Acting) a2 
            on a1.movie_id = a2.mid ) at
        inner join 
            degrees
        on 
            degrees.id = at.actor_id
            and
            degrees.dist < 6
            and at.aid != degrees.id
        ) a
    where Actor.id = a.aid
)
select count(*) 
from 
    (
    select name,  min(dist) as dist 
    from degrees
    group by  name
    ) t
where t.dist >= 1 and t.dist <= 3
---order by t.dist, t.name
;

