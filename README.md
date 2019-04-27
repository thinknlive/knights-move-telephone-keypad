# knights-move-telephone-keypad

Determine a data structure to represent the possible Knight's moves on a telephone keypad.
Given a length N, determine the number of distinct digit sequences that can be generated for that N.

Usage: node knights-move-telephone-pad.js <N> [Loglevel]

```
Keypad:

| 1 | 2 | 3 |
| 4 | 5 | 6 |
| 7 | 8 | 9 |
| * | 0 | # |
```

```
Possible moves:

var moves = [
  [ 0, [4, 6]],
  [ 1, [6, 8]],
  [ 2, [7, 9]],
  [ 3, [4, 8]],
  [ 4, [3, 9, 0]],
  [ 5, []],
  [ 6, [1, 7, 0]],
  [ 7, [2, 6]],
  [ 8, [1, 3]],
  [ 9, [2, 4]],
];
```
