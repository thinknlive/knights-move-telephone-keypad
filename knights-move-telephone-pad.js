// Version 2
// Usage: node knights-move-telephone-pad.js <N>

//1 2 3
//4 5 6
//7 8 9
//* 0 #

// 0 1 2 3
// 1 2 3 0
// 2 3 0 1
// 3 0 1 2

var moves = [
  /* 0 */ [4, 6],
  /* 1 */ [6, 8],
  /* 2 */ [7, 9],
  /* 3 */ [4, 8],
  /* 4 */ [3, 9, 0],
  /* 5 */ [],
  /* 6 */ [1, 7, 0],
  /* 7 */ [2, 6],
  /* 8 */ [1, 3],
  /* 9 */ [2, 4],
];

var args = process.argv.slice(2);
var maxdepth = args && args.length ? (parseInt(args[0],10)||1) : 1;
var cnt = 0;
var verbose = args && args.length > 1 ? !!(parseInt(args[1],10)||0) : false;

//verbose ? console.log('START the Knights! : maxdepth ['+maxdepth+']') : false;

function walker (depth, node, seq) {
  if (depth >= maxdepth) {
    cnt += 1;
    verbose ? console.log(
              //'cnt ['+cnt+']; '+
              seq.join('')+' '                                // The digit sequence
              +seq.slice(0).sort().join('')+' '               // Sorted
              +[ ...new Set(seq.slice(0).sort()) ].join(''))  // unique
            : false;
    return;
  }

  moves[node].forEach(
    (elt) => {
      seq.push(elt);
      walker(depth+1, elt, seq);
      seq.pop();
    });

}

moves.forEach(
  (elt, ndx) => {
    walker(1, ndx,  [ ndx ]);
  });

//verbose ? console.log('END: maxdepth ['+maxdepth+']; cnt ['+cnt+']') : false;
