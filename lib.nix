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

  grid = rec {
    fromString = s: s
      |> lib.splitString "\n"
      |> filter (e: e != "")
      |> map (lib.splitString "")
      |> map (filter (e: e != ""))
      |> filter (e: e != [])
      |> init;

    init = g: rec {
        state = g;
        width = state |> head |> length;
        height = state |> length;
        get = pos:
          elemAt (elemAt state pos.y) pos.x;
        find = char:
          let
            l = flat state;
            i = lib.lists.findFirstIndex (e: e == char) (-1) l;
          in
            vecToCoord [
              (lib.mod i width)
              (div i width)
            ];
        set = value: pos: 
          let
              visit = position: value:
                (lib.take position.y state) ++ [(visitRow (elemAt state position.y) position.x value)] ++ (lib.drop (position.y + 1) state);

              visitRow = row: x: value:
                (lib.take x row) ++ [value] ++ (lib.drop (x + 1) row);
          in
          init (visit pos value);
        wrap = char:
          let 
            blank = repeat char (m |> head |> length |> (e: e + 2));
          in init ([blank] ++ (map (e: [char] ++ e ++ [char]) m) ++ [blank]);

        print = s: state
          |> trace s
          |> map (e: trace (concat e) e)
          |> map (e: e)
          |> init;
        allCoords = lib.cartesianProductOfSets {x = lib.range 0 (state |> head |> length |> (e: e - 1)); y =  lib.range 0 (length state |> (e: e - 1));};

      };
  };


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