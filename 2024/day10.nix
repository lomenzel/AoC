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
  input = readFile ./day10.input
    |> lib.splitString "\n"
    |> map (lib.splitString "")
    |> map (filter (e: e != ""))
    |> map (map lib.toInt)
    ;


  inside =  pos:
  with pos;
    x >= 0 && y >= 0 && x < (input |> head |> length) && y < length input;

  directionDeltas = [
    {
      x = 1;
      y = 0;
    }
    {
      x = -1;
      y = 0;
    }
    {
      x = 0;
      y = 1;
    }
    {
      x = 0;
      y = -1;
    }
  ];

  allCoords = lib.cartesianProductOfSets {x = lib.range 0 (input |> head |> length |> (e: e - 1)); y =  lib.range 0 (length input |> (e: e - 1));};


  atCoord = pos:
    elemAt (elemAt input pos.y) pos.x;

  nachbarn = pos:  
  map (f:
          {
            x = pos.x + f.x;
            y = pos.y + f.y;
          }
          ) directionDeltas
;

  expand = n: l: lib.lists.unique (expandAll n l);

  expandAll =  n: l: map (e: nachbarn e  |> filter (inside)) l
          |> map (filter (e: atCoord e == n))
          |> flat
          ;

  part1 = allCoords
    |> filter (e: atCoord e == 0)
    |> map (e: foldl' (acc: curr: expand curr acc) [e] (lib.range 1 9))
    |> map length
    |> sum
    ;

  part2 = allCoords
    |> filter (e: atCoord e == 0)
    |> map (e: foldl' (acc: curr: expandAll curr acc) [e] (lib.range 1 9))
    |> map length
    |> sum
    ;

in
part2