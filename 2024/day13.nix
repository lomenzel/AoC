with builtins; let
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

  # mashines = [Mashine...] -> [Mashine...]
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


  # mashine = Mashine -> number | null
  cheapestWin = mashine:
  let 
    x1 = mashine.A.x;
    x2 = mashine.B.x;
    x3 = mashine.Prize.x;
    y1 = mashine.A.y;
    y2 = mashine.B.y;
    y3 = mashine.Prize.y;
    mul = l: n: if l == [] then [] else [((head l) * n)] ++ mul (tail l) n;
    substract = l1: l2: if l1 == [] then [] else [((head l1) - (head l2))] ++ (substract (tail l1) (tail l2));
    I = [x1 x2 x3];
    II = [y1 y2 y3];
    I' = mul I (head II);
    II' = mul II (head I);
    II'' = substract I' II';
    b =  (elemAt II'' 2) / (elemAt II'' 1);
    a = ((elemAt I 2) - (b * (elemAt I 1))) / (elemAt I 0);
  in
    winCost mashine a b
    ;

in part2 input

