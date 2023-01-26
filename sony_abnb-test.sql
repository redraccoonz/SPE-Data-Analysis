--  Please provide the ​SQL statement​ for these questions:

--  1) How many different listings were there on 2021-01-10? By how many different hosts?
select count(distinct l.id) as listings_unique,
       count(distinct l.host_id) as hosts_unique
from listings l inner join calendar c 
     on l.id = c.listing_id
where date(concat(c.year,'-',c.month,'-',c.day)) is date('2021-01-10')
group by 1,2


--  2) What are the top 10 most expensive (pricewise) listings?

select listing_id, price
from (select 
        listing_id,
        price,
        rank() over (partition by listing id order by price desc) as ranking   -- ranking
      from calendar
      ) as a    -- subquery alias
where a.ranking<11
order by a.profits desc


--  3) Which listing has the lowest ​Calendar​ vacancy rate?

with vacancy_ratios as (
    select listing_id,
           date(date) as date,

           --  total units, partitioned by listing, ordered by date
           count(available) over (partition by listing_id order by date) as total_units,

           --  total units vacant, partitioned by 
           count (case when available='t' then 1 else null end) 
             over (partition by listing_id order by date) as vacancy_total
    from calendar
),

select v.listing_id,
       v.date,
       v.vacancy_total/v.total_units as vacancy_rate
from vacancy_ratios v
group by 1,2,3


--  4) What 5 listings have had the most frequent day-over-day price increases?

-- lag / lead problem
-- Assumptions:  "most" as in "largest" price increase ?
-- Top 5 listings ?

with cte as (
    select listing_id,
       date(date) as date,
       price as date_price,
       lag(price) over (order by date) as yday_price,
       price - lag(price) as price_difference,
       dense_rank(price - lag(price)) 
         over (partition by listing_id order by date) as dense_ranking   -- ranking
from calendar
where dense_ranking<6
)

select listing_id,
       date,
       price_difference
from cte
order by 1,2,3 desc