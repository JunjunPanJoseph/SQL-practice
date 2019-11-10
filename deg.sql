with recursive degrees as (
    select distinct Actor_2.id as id,  Actor_1.name as from_name, Actor_2.name as to_name, Movie.title as title, 1 as dist
    from Actor as Actor_1, Actor as Actor_2, Movie, 
            ((Acting a1 
            inner join 
            (select movie_id as mid, actor_id as aid from Acting) a2 
            on a1.movie_id = a2.mid ) )a
    where lower(Actor_1.name) = lower('tom cruise')
        and Actor_1.id = a.actor_id
        and Movie.id = a.movie_id
        and Actor_2.id = a.aid
    union ALL

    select distinct a.aid as id, a.to_name as from_name, Actor.name as to_name, Movie.title as title, a.dist + 1 as dist
    from Actor, Movie, (
            (Acting a1 
            inner join 
            (select movie_id as mid, actor_id as aid from Acting) a2 
            on a1.movie_id = a2.mid ) at
        inner join 
            degrees
        on 
            degrees.id = at.actor_id
            and
            degrees.dist < 2
            and at.aid != degrees.id
        ) a
    where Actor.id = a.aid
        and Movie.id = a.movie_id
)
select min(dist)
from degrees
where lower(to_name) = lower('Robert Downey Jr.')
;