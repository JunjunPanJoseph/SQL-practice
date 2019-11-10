-- Q1
create or replace view Q1(Name, Country) as 
select Company.name, Company.Country
from Company
where Company.country != 'Australia'
    and company.country is not null
;
-- Q2
create or replace view Q2(Code) as
select code
from executive
group by code
having count(code) > 5
;
-- Q3
create or replace view Q3(Name) as
select company.name
from company, category
where company.code = category.code 
    and category.sector = 'Technology'
;
-- Q4
create or replace view Q4(Sector, Number) as
select sector, count(distinct (industry))
from category
group by sector
;
-- Q5
create or replace view Q5(Name) as
select distinct(executive.person)
from executive, company, category
where executive.code = company.code 
    and company.code = category.code
    and category.sector = 'Technology'
;
-- Q6
create or replace view Q6(Name) as
select company.name
from company, category
where company.country = 'Australia'
    and company.code = category.code
    and category.sector = 'Services'
    and company.zip like '2%'
;
-- Q7

create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as
select a1."Date", a1.code, a1.volume, a2.price, a1.price, a1.price - a2.price, 100 * (a1.price - a2.price)/a2.price
from ASX as a1, ASX as a2
where a2.code = a1.code
    and a2."Date" = 
    (
        select max("Date")
        from ASX
        where ASX.code = a1.code
            and ASX."Date" < a1."Date"
    )
;




-- Q8
create or replace view Q8("Date", Code, Volume) as 
select a."Date", a.code, a.volume 
from ASX as a 
where a.volume = (select max(volume) as volume from ASX where "Date" = a."Date") 
order by a."Date", a.code 
;


-- Q9
create or replace view Q9(Sector, Industry, Number) as 
select Category.sector, Category.industry, count(Category.industry)
from Category
group by category.sector,  category.industry
order by category.sector, category.industry
;
-- Q10

create or replace view Q10(Code, Industry) as
select category.code, category.industry
from category
where category.industry is not null 
    and category.industry in (
    select category.industry as industry
    from category
    group by(category.industry)
    having count(category.industry) = 1
)
;
-- Q11
create or replace view Q11(Sector, AvgRating) as
select category.sector, avg(rating.star)
from category, rating
where category.code = rating.code
group by category.sector
order by avg(rating.star) desc
;
-- Q12
create or replace view Q12(Name) as
select executive.person
from executive
group by executive.person
having count(executive.person) > 1
;

-- Q13
create or replace view Q13(Code, Name, Address, Zip, Sector) as
select cat.code, comp.name, comp.address, comp.zip, cat.sector
from category as cat, company as comp
where cat.code = comp.code
    and comp.country is not null
    and comp.country = 'Australia'
    and comp.country = all(
        select company.country
        from company, category
        where company.code = category.code
            and category.sector = cat.sector 
    )
;
-- Q14
create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as 
with dateasx as
(
    select ASX.code, min(ASX."Date") as s, max(ASX."Date") as l
    from ASX
    group by ASX.code
)
select dateasx.code, b.price, e.price, e.price - b.price, 100 * (e.price - b.price) / b.price as gain
from dateasx, ASX as b, ASX as e
where b."Date" = dateasx.s and b.code = dateasx.code
    and e."Date" = dateasx.l and e.code = dateasx.code
order by gain DESC, dateasx.code
;
-- Q15
create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as
select a.*, b.i, b.v, b.a
from 
    (select ASX.code as code, min(ASX.price), avg(ASX.price), max(ASX.price) 
    from ASX
    group by ASX.code
    )a, 
    (
        select Q7.code as code, min(Q7.gain) as i, avg(Q7.gain) as v, max(Q7.gain) as a
        from Q7
        group by (Q7.code)
    )b
where a.code = b.code
;
--Q16
create or replace function Q16_1() returns trigger as $$ 
begin 
    if (new.person = old.person) then 
        if ((select count(Executive.person) 
                    from Executive  
                    where Executive.person = new.person 
        ) > 1) then 
                raise exception '% can not be an executive of more then one company', new.person; 
        end if; 
        return new; 
    else 
        if ((select count(Executive.person)  
                    from Executive  
                    where Executive.person = new.person 
        ) > 0) then 
                raise exception '% can not be an executive of more then one company', new.person; 
        end if; 
        return new; 
    end if;
end;
$$ language plpgsql; 

create trigger Q16_1 
before update on Executive 
for each row 
execute procedure Q16_1();

create or replace function Q16_2() returns trigger as $$ 
begin 
    if ((select count(Executive.person) 
                from Executive  
                where Executive.person = new.person 
    ) > 0) then 
            raise exception '% can not be an executive of more then one company', new.person; 
    end if; 
    return new; 
end;
$$ language plpgsql; 

create trigger Q16_2 
before insert on Executive 
for each row 
execute procedure Q16_2();



-- Q17
create or replace function Q17() returns trigger as $$  
declare 
q17_gain numeric; 
q17_max numeric; 
q17_min numeric; 
begin  
    q17_gain := (select Q7.gain  
                        from Q7 
                        where Q7.code = new.code 
                            and Q7."Date" = new."Date" )
                    ; 
    q17_min := (select min(Q7.gain)  
                        from Q7, Category as c1, category as c2 
                        where Q7."Date" = new."Date" 
                            and Q7.code = c1.code 
                            and new.code = c2.code 
                            and c1.sector = c2.sector 
                    ); 
    q17_max := (select max(Q7.gain)  
                        from Q7, Category as c1, category as c2 
                        where Q7."Date" = new."Date" 
                            and Q7.code = c1.code 
                            and new.code = c2.code 
                            and c1.sector = c2.sector 
                    ); 
    if (q17_gain = q17_min) then  
        update rating  
        set star = 1 
        where rating.code = new.code; 
    end if;
    if (q17_gain = q17_max) then 
        update rating  
        set star = 5 
        where rating.code = new.code; 
    end if; 
    return new;
end; 
$$ language plpgsql;  

create trigger Q17 
after insert on ASX  
for each row 
execute procedure Q17();

--Q18


create or replace function Q18() returns trigger as $$ 
begin 
    insert into ASXLog values (CURRENT_TIMESTAMP, old."Date", old.code, old.volume, old.price); 
return new;
end; 
$$ language plpgsql;
  
create trigger Q18 
after update on ASX  
for each row 
execute procedure Q18();





