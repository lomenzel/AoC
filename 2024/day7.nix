with builtins; let 
  lib = (import <nixos> {}).lib;

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;
  input = readFile ./day7.input
    |> lib.splitString "\n"
    |> map (e: {
      res = head (lib.splitString ": " e) |> lib.toInt;
      operants = elemAt  (lib.splitString ": " e) 1
        |> lib.splitString " "
        |> map lib.toInt;
    })
    ;

  pow = b: e: current:
    if e == 0 then current else
    pow b (e - 1) (b * current);

  # isValid = {res, operants}:
    

  possibleOperators = n:
    if n == 0 then [] else lib.range 0 ((pow 2 (n - 1) 1) - 1)
    |> map (bin [])
    |> map (fill (n - 1))
    ;
  
  possibleOperatorsPart2 = n:
    if n == 0 then [] else lib.range 0 ((pow 3 (n - 1) 1) - 1)
    |> map (tern [])
    |> map (fill (n - 1))
    ;

  

  fill = n: list:
    (lib.range 0 (n - (length list) - 1)|> map (e: 0)) ++ list;

  bin = current: n:
    if n == 0 then [0] ++ current else
    if n == 1 then [1] ++ current else
    bin [(lib.mod n 2)] (div n 2) ++ current;

  tern = current: n:
    if n == 0 then [0] ++ current else
    if n == 1 then [1] ++ current else
    if n == 2 then [2] ++ current else
    tern [(lib.mod n 3)] (div n 3) ++ current;

  calc = operants: operators:
    if operators == [] then  operants else
    if head operators == 0 then calc ([((head operants) * (elemAt operants 1))] ++ (operants |> tail |> tail)) (tail operators)  else
    if head operators == 1 then calc ([((head operants) + (elemAt operants 1))] ++ (operants |> tail |> tail))  (tail operators) else
    calc ([((toString (head operants)) + (toString (elemAt operants 1)) |> lib.toInt)] ++ (operants |> tail |> tail))  (tail operators);    


  "Part 1" = input
    |> map (e: (possibleOperators (length e.operants)) 
      |> map (calc e.operants) 
      |> map (filter (f: f == e.res))
      |> filter (f: f != [])
      |> map head
      |> (f: if f == [] then 0 else head f )
    )
    |> sum
    ;
  "Part 2" = input
    |> map (e: (possibleOperatorsPart2 (length e.operants)) 
      |> map (calc e.operants) 
      |> map (filter (f: f == e.res))
      |> filter (f: f != [])
      |> map head
      |> (f: if f == [] then 0 else head f )
    )
    |> sum
    ;
in 
  {inherit "Part 1" "Part 2";}
  #possibleOperatorsPart2 3