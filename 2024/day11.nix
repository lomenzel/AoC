with builtins; let
  lib = (import <nixos> { }).lib;

  sum = list: foldl'(acc: curr: acc + curr) 0 list;
  product = list: foldl' (acc: curr: acc * curr) 1 list;
  concat = list: foldl' (acc: curr: acc + curr) "" list;
  flat = list: foldl' (acc: curr: acc ++ curr) [ ] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [ ] else [ e ] ++ repeat e (n - 1);
  odd = n: ! even n;
  input = readFile ./day11.input
    |> lib.splitString " "
    |> map lib.toInt
  ;

  rules = n:
  let 
    s = toString n;
    len = stringLength s;
  in
    if n == 0 then [1] else
    if lib.mod len 2 == 1 then [(2024 * n)] else
    [
      (substring 0 (len / 2) s |> lib.toIntBase10)
      (substring (len / 2) len s |> lib.toIntBase10)
    ];


  blink = h: n: s: 
  if n == 0 then {inherit h; value = 1;} else
  if hasAttr (toString n) h && hasAttr (toString s) h.${toString n} then
     {value =  h.${toString n}.${toString s};
     inherit h;
     }
  else
  rules s 
   # |> map (blink h (n - 1))
    |> foldl' (acc: curr: let

      next = blink acc.h (n - 1) curr;

    in {
      h = updateH next.h (n - 1) curr next.value;
      sum = next.value + acc.sum; 
    }
    
    ) {inherit h; sum = 0;}
    |> (e: {h = updateH e.h n s e.sum; value = e.sum;})
    #|> (e: if s == 2 then trace "n = ${toString n}; e = ${toString e.value} s = ${toString s};" e else e )
    ;
    
  updateH = h: n: s: value:
    lib.recursiveUpdate h { "${toString n}" = {
      "${toString s}" = value;
    };}
  ;


  generate = lib.range 21 50
    |> map (e:
      trace "\"${toString e}\" = ${toString (blink e 0)};" e
    )
    ;

  part1 = input
    |> map (blink {} 25)
    |> map (e: e.value)
    |> sum;

  todo =[ 5851763 6571 0 526746 23 69822 9 989 ];

  part2 = input
    |> map (e: (blink (prepareH {} 75 e) 75 e).value)
    |> map (e: trace (toString e) e)
    |> sum;



  prepareH = h: n: s:
  (foldl' (acc: curr: 
  trace "${toString curr}"
  (blink acc curr s).h
 ) h (lib.range 0 n));

  # part2 = blink 75 input;
in part1

