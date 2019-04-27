---------------------------------------------------------------------------
-- This has been tested in SQLite only.
-- It uses CTEs to do a depth first traversal.
--
-- Other DBs, may not have CTEs, or do concat and group_concat differently
--
-- https://sqlite.org/lang_with.html
-- ------------------------------------------------------------------------
with recursive
depth (n) as (
  values (8)  -- How deep to go
),
--
-- The Tree
--
moves (node, child) as (
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
walker (level, node,  child, result) AS (
  select
    1, node, child, ''
  from
    moves
  where node in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
  UNION ALL
  SELECT
    level+1,
    b.node,
    b.child,
    cast(a.result as text)||cast(a.child as text)
  FROM
    walker a, moves b
  where
    a.child=b.node
    and level <= (select n from depth)
  order by 2 desc
),
results as (
  select
    knights
  from (
    select distinct
    ' '||result as knights
  from
    walker
  where level = (select max(level) from walker)
  ) A
  where
    instr(knights, 4) = 0
    and instr(knights, 6) = 0
  order by
    knights
),
--
-- Split out the results into individual digits
--
cte (value, elt, ndx) as (
  select
    knights, null, 0
  from
    results
  union all
  select
    value,
    substr(value, (ndx % 10)+1, 1),
    (ndx % 10)+1
  from
    cte
  where
    ndx < length(value)
),
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

