with builtins; let 
  lib = (import <nixos> {}).lib;

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;
  flat = list: lib.fold (acc: curr: acc ++ curr) [] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [] else [e] ++ repeat e (n - 1);
  odd = n: ! even n;
  input = readFile ./day9.input
    |> lib.splitString ""
    |> filter (e: e != "")
    |> map lib.toInt
    ;


  blocks = input
    |> length
    |> lib.range 1
    |> map (e: let
      n = elemAt input (e - 1);
    in
      if even e then
        repeat "." n
      else
        repeat (div e 2) n
    )
    |> flat
    ;

  blockgroups = input
    |> length
    |> lib.range 1
    |> map (e: let
      n = elemAt input (e - 1);
    in
      if even e then
        repeat "." n
      else
        repeat (div e 2) n
    )
    |> filter (e: e != [])
    ;

  totalUsedBlocs = blocks
    |> filter (e: e != ".")
    |> length
    ;

  revBlocks = blocks
    |> filter (e: e!= ".")
    |> lib.reverseList
    ;

  countDot = n:  elemAt dotCounts n
    #|> (e: trace "asked for dotcount at ${toString n}" e)
    ;

  dotCounts = blocks
    |> lib.take totalUsedBlocs
    |> foldl' (acc: curr: #trace "dotcount calculated until ${toString  (length acc.l)}"
      (if curr == "." then 
        {l = acc.l ++ [(acc.n + 1)]; n = acc.n + 1;} 
      else 
        {inherit (acc) n; l =  acc.l ++ [acc.n];}
    )) {l = []; n = 0;}
    |> (e: e.l)
    |> (e: trace "dotCountLength ${toString (length e)}" e)
    ;

  checksum = lower: higher: higher
    |> (e: lib.min e totalUsedBlocs)
    |> dec
    |> lib.range lower
    |> map (e:
    let 
      char = elemAt blocks e;
      dots = countDot e;
    in
      if char == "." then 
        (elemAt revBlocks (dots - 1)) * e
      else
        (char) * e
    )
    |> sum
    ;


  firstFit = l: size:
    #trace "size = ${toString size}"
    (firstFitrec l size 0)
    ;

  firstFitrec = l: size: n:
    if l == [] then null else
    if (head l) == [] then firstFitrec (tail l) size (inc n) else
    if (head (head l) == ".") && (length (head l) >= size) then n else
    firstFitrec (tail l) size (inc n);

  place = l: e:
  let 
    i = firstFit l (length e);
  in
    if i == null then l ++ [e] else
    (lib.take i l) ++( ([e] ++ [( (repeat "." ((length(elemAt l i) - (length e)))))])  |> filter (e: e != [])) ++ (lib.drop (i + 1) l) ++ [(repeat "." (length e))]
    ;


  placeRec = l: pos:
  let 
    currentindex = (length l) - pos - 1;
    toPlace = elemAt l currentindex;
    i = firstFit (lib.take currentindex l) (length toPlace);
    len = length l;
  in
    if head toPlace == "." then placeRec l (inc pos) else
    if currentindex == 0 then l else
    if i == null then placeRec l (inc pos) else
    placeRec ((place (lib.take currentindex l) toPlace) ++ (lib.drop (inc currentindex) l)) pos
    ;
 
  part1 = 
    (checksum 0 10000) + 
    (checksum 10000 20000) + 
    (checksum 20000 30000) + 
    (checksum 30000 40000) + 
    (checksum 40000 totalUsedBlocs);

  part2 = placeRec blockgroups 0
    |> flat
    |> foldl' (acc: curr: if curr == "." then {i = inc acc.i; value = acc.value;} else {i = inc acc.i; value = acc.value + (acc.i * curr);}) {i = 0; value = 0;}
    |> (e: e.value)
    ;
in
  part2

  