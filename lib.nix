with builtins; rec {
  lib = (import <nixos> { }).lib;

  sum = list: foldl'(acc: curr: acc + curr) 0 list;
  product = list: foldl' (acc: curr: acc * curr) 1 list;
  concat = list: foldl' (acc: curr: acc + curr) "" list;
  minimum = list:
    if list == [] then null else
    foldl' (acc: curr: lib.min acc curr) (head list) list;
  maximum = list:
    if list == [] then null else
    foldl' (acc: curr: lib.max acc curr) (head list) list;
  join = separator: list: list
    |> map (e: e + separator)
    |> concat;
  flat = list: foldl' (acc: curr: acc ++ curr) [ ] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [ ] else [ e ] ++ repeat e (n - 1);
  odd = n: ! even n;

    # l = [number number] -> {x = number; y = number;}
  vecToCoord =  l:
    {
      x = head l;
      y = elemAt l 1;
    };


  modPositive = base: int: lib.mod base int |> (e: e + int) |> (e:  lib.mod e  int);

  printMap = m: m
    |> trace (repeat "-" (length (head m)) |> concat)
    |> map (e: trace (concat e) e)
    |> map (e: e)
    ;


    # pos1 = Position; pos2 = Position; -> Position
  addPos = pos1: pos2:
    { 
      x = pos1.x + pos2.x;
      y = pos1.y + pos2.y;
    };

  # pos = Position; n = number; -> Position
  mulPos = pos: n:
    {
      x = pos.x * n;
      y = pos.y * n;
    };

}