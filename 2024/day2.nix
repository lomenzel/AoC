with builtins; with (import ../lib.nix); let
  realinput = readFile ./day2.input;
  parseInput = input: input
    |> lib.splitString "\n"
    |> map (e: lib.splitString " " e |> filter (e: e!= "") |>  map (e: lib.toInt e))
    |> filter (e: e != []);
  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  ascending = list: 
    if length list < 2 then true else
    (head list) <= (elemAt list 1) && ascending (tail list);
  decending = list: 
    if length list > 1 then
    (head list) >= (elemAt list 1) && decending (tail list) else true;

  ordered = list:
    decending list || ascending list;

  abs = int:
    if int < 0 then (0-int) else int;
  
  difference = a: b:
    abs (a - b);

  graceful = lower: upper: list:
    if length list < 2 then true else
    (difference (head list) (elemAt list 1)) <= upper &&
    (difference (head list) (elemAt list 1)) >= lower &&
    graceful lower upper (tail list);

  save = list:
    ordered list && (graceful 1 3) list;

  oneMissing = list: list
    |> length
    |> lib.range 0
    |> map (removeIndex list);

  removeIndex = list: index:
    (lib.sublist 0 index list) ++ (lib.sublist (index + 1) (length list) list);

  tolerable = list:
    if save list then true else
    (list
      |> oneMissing
      |> filter save
      |> length) > 0;



  part1 = input: input
    |> parseInput
    |> filter save
    |> length
    ;

  part2 = input: input
    |> parseInput
    |> filter tolerable
    |> length
    ;

  tests =
  let testinput = ''
          7 6 4 2 1
          1 2 7 8 9
          9 7 6 2 1
          1 3 2 4 5
          8 6 4 4 1
          1 3 6 7 9
        '';
  in {
    part1 = [{
        input = testinput;
        expected = 2;
      }];
      part2 = [{
        input = testinput;
        expected = 4;
      }];
  };
in 
  {inherit part1 part2 tests;}