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

  part1 = input: input
    |> split ''mul\(([0-9]+),([0-9]+)\)''
    |> filter (e: !isString e)
    |> map (e: map (lib.toInt) e |> product)
    |> sum
    ;

  part2 =input: input
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
  {inherit  part1 part2;
    tests = {
      part1 = [{
        input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
        expected = 161;
      }];
      part2 = [{
        input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
        expected = 48;
      }];
    };
  }