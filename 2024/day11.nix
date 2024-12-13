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
    |> map (s: {stone = s; count = 1;})
  ;


  # n = number; stones [{stone = number; count = number;}] -> [{stone = number; count = number;}]
  blink = n: stones:
    if n == 0 then stones else
    map rules stones 
      |> flat
      |> groupBy (e: toString e.stone)
      |> lib.attrsToList
      |> map (e: e.value)
      |> map (e: {stone = (head e).stone; count = map (f: f.count) e |> sum;})
      |> blink (n - 1)

;
  # n = {stone = number; count = number} -> [{stone = number; count = number}]
  rules = n:
  let 
    s = toString n.stone;
    len = stringLength s;
  in
    if n.stone == 0 then [(n // {stone = 1;})] else
    if lib.mod len 2 == 1 then [(n // {stone = n.stone * 2024;})] else
    [
      (n // { stone = substring 0 (len / 2) s |> lib.toIntBase10; })
      (n // { stone = substring (len / 2) len s |> lib.toIntBase10; })
    ];

  part1 = 
    blink 25 input
    |> map (e: e.count)
    |> sum
    ;
  part2 = 
    blink 75 input
    |> map (e: e.count)
    |> sum
    ;


in { inherit part1 part2; }