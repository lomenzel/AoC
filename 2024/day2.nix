with builtins; let 
  lib = (import <nixos> {}).lib;
  input = readFile ./day2.input
    |> lib.splitString "\n"
    |> map (e: lib.splitString " " e |> map (e: lib.toInt e));
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



  "Part 1" = input
    |> filter save
    |> length
    ;

  "Part 2" = input
    |> filter tolerable
    |> length
    ;
in 
  {inherit "Part 1" "Part 2";}
