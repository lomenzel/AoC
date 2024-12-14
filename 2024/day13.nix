with builtins; with (import ../lib.nix); let

  # [Mashine...]
  realinput = readFile ./day13.input;
  parseInput = input: input
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






  # mashines = [Mashine...] -> number
  part1 = mashines: mashines
    |> parseInput
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
  part2 = mashines: machines
    |> parseInput
    |> convertInputToPart2
    |> map cheapestWin
    |> filter (e: e != null)
    |> sum;


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

  tests = {
    part1 = [{
      input = ''
        Button A: X+94, Y+34
        Button B: X+22, Y+67
        Prize: X=8400, Y=5400

        Button A: X+26, Y+66
        Button B: X+67, Y+21
        Prize: X=12748, Y=12176

        Button A: X+17, Y+86
        Button B: X+84, Y+37
        Prize: X=7870, Y=6450

        Button A: X+69, Y+23
        Button B: X+27, Y+71
        Prize: X=18641, Y=10279
      '';
      expected = 480;
    }];
    part2 = [];
  };

in { inherit part1 part2 tests; }

