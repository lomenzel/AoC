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

  part1 = allCoords
    |> filter (e: atCoord e == 0)
    |> map (e:
      e // {
        erreichbar = nachbarn e
          |> filter (inside)
          |> filter (e: atCoord e == 1)
          |> map (e: nachbarn e  |> filter (inside))
          |> map (filter (e: atCoord e == 2))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 3))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 4))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 5))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 6))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 7))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 8))
          |> flat
          |> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 9))
          |> flat
          |> lib.lists.unique
          ;
      }
    )
    |> map (e: length e.erreichbar)
    |> sum
    ;

  part2 = allCoords
    |> filter (e: atCoord e == 0)
    |> map (e:
      e // {
        erreichbar = nachbarn e
          |> filter (inside)
          |> filter (e: atCoord e == 1)
          |> map (e: nachbarn e  |> filter (inside))
          |> map (filter (e: atCoord e == 2))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 3))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 4))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 5))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 6))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 7))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 8))
          |> flat
          #|> lib.lists.unique
          |> map (e: nachbarn e |> filter (inside))
          |> map (filter (e: atCoord e == 9))
          |> flat
          #|> lib.lists.unique
          ;
      }
    )
    |> map (e: length e.erreichbar)
    |> sum
  ;

in
part2