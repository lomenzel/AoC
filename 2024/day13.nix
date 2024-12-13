with builtins; let
  lib = (import <nixos> { }).lib;

  sum = list: foldl'(acc: curr: acc + curr) 0 list;
  product = list: foldl' (acc: curr: acc * curr) 1 list;
  concat = list: foldl' (acc: curr: acc + curr) "" list;
  minimum = list:
    if list == [] then null else
    foldl' (acc: curr: lib.min acc curr) (head list) list;
  maximum =
    if list == [] then null else
    list: foldl' (acc: curr: lib.max acc curr) (head list) list;
  join = separator: list: list
    |> map (e: e + separator)
    |> concat;
  flat = list: foldl' (acc: curr: acc ++ curr) [ ] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [ ] else [ e ] ++ repeat e (n - 1);
  odd = n: ! even n;

  # [Mashine...]
  input = readFile ./day13.input
    |> lib.splitString "\n\n"
    |> map (lib.splitString "\n")
    |> map (filter (e: e != ""))
    |> filter (e: e != [])
    |> map ( map (split ''([0-9]+)''))
    |> map ( map ( filter (e: !isString e)))
    |> map (map flat)
    |> map (map (map lib.toInt))
    |> map (mashine: 
      {
        A = vecToCoord (head mashine);
        B = vecToCoord (elemAt mashine 1);
        Prize = vecToCoord (elemAt mashine 2);
      }
    )
    ;



/* TYPES

  Position = 
  {
    x = number;
    y = number;
  }

  Mashine = 
  {
    A = Position;
    B = Position;
    Prize = Position;
  }

*/

  # mashine = Mashine -> [number...]
  btnPressRange = mashine:
    let
      maxx = lib.max mashine.A.x mashine.B.x;
      maxy = lib.max mashine.A.y mashine.B.y;
      minx = lib.min mashine.A.x mashine.B.x;
      miny = lib.min mashine.A.y mashine.B.y;
      px = mashine.Prize.x;
      py = mashine.Prize.y;
      minPressY = div py maxy;
      minPressX = div px maxx;
      maxPressY = div py miny;
      maxPressX = div px minx;
      max = lib.min maxPressX maxPressY;
      min = lib.max minPressX minPressY;
    in
      lib.range min max;

  # mashine = Mashine -> number | null
  cheapestWin = mashine: btnPressRange mashine
    |> map (n:
      lib.findFirst (a:
        winCost mashine a (n - a) != null
      ) null (lib.range 0 n)
      |> (sola: if sola == null then null else [sola (n - sola)])
    )
    |> filter (e: e != null)
    |> map (sol:
      let
        a = head sol;
        b = elemAt sol 1;
      in 
        winCost mashine a b
    )
    |> minimum
    ;
    
  # mashine = Mashine; a = number; b = number -> number | null
  winCost = mashine: a: b:
    let 
      nA = mulPos mashine.A a;
      nB = mulPos mashine.B b;
      pos = addPos nA nB;
    in
      if mashine.Prize != pos then null else
      (a * 3) + b;


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

  # l = [number number] -> {x = number; y = number;}
  vecToCoord =  l:
    {
      x = head l;
      y = elemAt l 1;
    };


  # mashines = [Mashine...] -> number
  part1 = mashines: mashines
    |> map cheapestWin
    |> filter (e: e != null)
    |> sum;

  convertInputToPart2 = mashines:
    map (mashine:
      mashine // {Prize = addPos mashine.Prize {
        x = 10000000000000;
        y = 10000000000000;
      };}) mashines;

  # mashines = [Mashine...] -> number
  part2 = mashines: mashines
    |> convertInputToPart2
    |> part1;


in 
input |> convertInputToPart2 |> head |> btnPressRange