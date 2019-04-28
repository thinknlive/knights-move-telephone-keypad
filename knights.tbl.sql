---------------------------------------------------------------------------
-- This has been tested in SQLite only.
-- It uses CTEs to do a depth first traversal.
--
-- It also breaks the results into multiple queries and tables
-- NOTE: Even for relatively small depth, this can generated HUGE tables
-- 
-- https://sqlite.org/lang_with.html
-- ------------------------------------------------------------------------
drop table if exists knights_walker
;
create table knights_walker (lvl int, node int, child int, moves text)
;
with recursive
depth (n) as (
  values (16)  -- How deep to go
),
--
-- The Tree
--
initial_moves (node, child) as (
values
  (0, 4),
  (0, 6),
  (1, 6),
  (1, 8),
  (2, 7),
  (2, 9),
  (3, 4),
  (3, 8),
  (4, 3),
  (4, 9),
  (4, 0),
  (5, null),
  (6, 1),
  (6, 7),
  (6, 0),
  (7, 2),
  (7, 6),
  (8, 1),
  (8, 3),
  (9, 2),
  (9, 4)
),
--
-- Recursive CTE to traverse The Tree
--
walker (lvl, node,  child, moves) AS (
  select
    1, node, child, ''
  from
    initial_moves
  where node in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
  UNION ALL
  SELECT
    lvl+1,
    b.node,
    b.child,
    cast(a.moves as text)||cast(a.child as text)
  FROM
    walker a, initial_moves b
  where
    a.child=b.node
    and lvl <= (select n from depth)
  order by 2 desc
)
insert into knights_walker (lvl, node, child, moves)
select lvl, node, child, moves from walker
;

--
-- Extract just the moves of the length we are interested into another table.
--
drop table if exists knights_seq
;
create table knights_seq (moves text)
;
insert into knights_seq (moves)
select distinct moves
from (
  select moves
  from
    knights_walker
  where lvl = (select max(lvl) from knights_walker)
) A
order by
  moves

--
-- Split out the results into individual digits
--
drop table if exists knights_chopped
;
CREATE TABLE knights_chopped (moves text, move int, ndx int)
;
with
cte (value, elt, ndx) as (
  select
    moves, null, 0
  from
    knights_seq
  union all
  select
    value,
    cast(substr(value, (ndx % 10)+1, 1) as int),
    (ndx % 10)+1
  from
    cte
  where
    ndx < length(value)
)
insert into knights_chopped (moves, move, ndx)
select value, elt, ndx
from cte
;

--
-- Get digits, sort and group
--
srtd_digits as (
  select
    value,
    group_concat(elt,'') as elt
  from (
    select
      value, elt
    from
      cte
    where
      elt is not null
    order by
      value, elt
  )
  group by value
),
--
-- Get unique digits, sort and grou
--
uniq_digits as (
  select
    value,
    group_concat(elt,'') as elt
  from (
    select distinct
      value, elt
    from
      cte
    where
      elt is not null
    order by
      value, elt
  )
  group by value
)
--
-- Finally...
--
select distinct
  results.knights,
  srtd_digits.elt as sorted_digits,
  uniq_digits.elt as unique_digits
from
  results, srtd_digits, uniq_digits
where
  results.knights = srtd_digits.value
  and results.knights = uniq_digits.value
  and uniq_digits.value = srtd_digits.value
;

