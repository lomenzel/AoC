with builtins; let 
  lib = (import <nixos> {}).lib;
  input = readFile ./day1.input
    |> lib.splitString "\n"
    |> map (e: lib.splitString "   " e |> map (e: lib.toInt e))
    |> (raw: [ 
          (map (e: head e) raw)
          (map (e: elemAt e 1) raw)
       ]);
  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  calcApperances = attrSet: list:
    if list == [] then attrSet else
    calcApperances (attrSet // {"${list |> head |> toString}" = if hasAttr (list |> head |> toString) attrSet then attrSet.${list |> head |> toString} + 1 else 1;}) (tail list);

  apperances = calcApperances {} (elemAt input 1);

  "Part 1" = input
    |> map (lib.sort (a: b: a < b))
    |> (prev: lib.zipLists (head prev) (elemAt prev 1))
    |> map (e: (lib.max e.fst e.snd) - (lib.min e.fst e.snd))
    |> sum;
  "Part 2" = input
    |> head
    |> map (e: if hasAttr (toString e) apperances then e * apperances.${toString e} else 0)
    |> sum;
in 
  {inherit "Part 1" "Part 2";}
