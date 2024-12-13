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
}