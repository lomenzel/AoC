with builtins; let 
  lib = (import <nixos> {}).lib;
  input = readFile ./day3.input;

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;
 
  prettify = list:
    if ! isNull(elemAt list 3) then "t" else
    if ! isNull(elemAt list 4) then "f" else
    head list;

  "Part 1" = input
    |> split ''mul\(([0-9]+),([0-9]+)\)''
    |> filter (e: !isString e)
    |> map (e: map (lib.toInt) e |> product)
    |> sum
    ;

  "Part 2" = input
    |> split ''(mul\(([0-9]+),([0-9]+)\))|(do\(\))|(don't\(\))''
    |> filter (e: !isString e)
    |> map (prettify)
    |> concat
    |> split "f[fmul()0-9,]*t"
    |> filter isString
    |> concat
    |> split "f[fmul()0-9,]*$"
    |> filter isString
    |> concat
    |> split ''mul\(([0-9]+),([0-9]+)\)''
    |> filter (e: !isString e)
    |> map (e: map (lib.toInt) e |> product)
    |> sum
    ;
in 
  {inherit "Part 1" "Part 2";}