with builtins; let 
  lib = (import <nixos> {}).lib;

  realinput = readFile ./day1.input;

  parseInput = input: input
    |> lib.splitString "\n"
    |> filter (e: e != "")
    |> map (e: lib.splitString "   " e |> map (e: lib.toInt e))
    |> (raw: [ 
          (map (e: head e) raw)
          (map (e: elemAt e 1) raw)
       ]);
  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  calcApperances = attrSet: list:
    if list == [] then attrSet else
    calcApperances (attrSet // {"${list |> head |> toString}" = if hasAttr (list |> head |> toString) attrSet then attrSet.${list |> head |> toString} + 1 else 1;}) (tail list);

  apperances = input: calcApperances {} (elemAt input 1);

  part1 = input: input |> parseInput
    |> map (lib.sort (a: b: a < b))
    |> (prev: lib.zipLists (head prev) (elemAt prev 1))
    |> map (e: (lib.max e.fst e.snd) - (lib.min e.fst e.snd))
    |> sum
    ;
  part2 = s:
    let input = parseInput s;
    in
     input
    |> head
    |> map (e: if hasAttr (toString e) (apperances input) then e * (apperances input).${toString e} else 0)
    |> sum;

  tests = let
    input = ''
        3   4
        4   3
        2   5
        1   3
        3   9
        3   3
      '';
      in {
    part1 = [{
      inherit input;
      expected = 11;
    }];
    part2 = [{
      inherit input;
      expected = 31;
    }];
  };
in 
  {inherit part1 part2 tests; solved = part1 realinput;}
