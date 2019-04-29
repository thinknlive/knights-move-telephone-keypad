---------------------------------------------------------------------------
-- This has been tested in SQLite only.
-- It uses CTEs to do a depth first traversal.
--
-- Other DBs, may not have CTEs, or do concat and group_concat differently
--
-- https://sqlite.org/lang_with.html
-- ------------------------------------------------------------------------
.timer on
with recursive
depth (n) as (
  values (14)  -- How deep to go
),
moves (node, child) as (
values
  (0, 4), (0, 6),
  (1, 6), (1, 8),
  (2, 7), (2, 9),
  (3, 4), (3, 8),
  (4, 3), (4, 9), (4, 0),
  (5, null),
  (6, 1), (6, 7), (6, 0),
  (7, 2), (7, 6),
  (8, 1), (8, 3),
  (9, 2), (9, 4)
),
--
-- Recursive CTE to traverse The Tree
--
walker (lvl, node,  child, moves) AS (
  select
    0, node, child, ''
  from
    moves
  where node in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
  UNION ALL
  SELECT distinct
    lvl+1,
    a.node,
    b.child,
    cast(a.moves as text)||cast(a.child as text)
  FROM
    walker a, moves b
  where
    a.child=b.node -- and (a.child not in (4, 6))
    and lvl < (select n from depth)
  order by 2 desc
)
select lvl, count(*) as cnt from (
  select lvl, moves, count(*) as cnt
  from
    walker
  where lvl = (select n from depth)
  group by lvl, moves
  having max(length(moves))
) A
group by lvl
;
