with builtins; let
  lib = (import <nixos> { }).lib;

  sum = list: foldl'(acc: curr: acc + curr) 0 list;
  product = list: foldl' (acc: curr: acc * curr) 1 list;
  concat = list: foldl' (acc: curr: acc + curr) "" list;
  flat = list: foldl' (acc: curr: acc ++ curr) [ ] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [ ] else [ e ] ++ repeat e (n - 1);
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
#|> filter (e: e != [])
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
i = trace "placing: ${toString (head e)}"
 (firstFit l (length e));
in
if i == null then l ++ [e] else
(lib.take i l) ++( ([e] ++ [( (repeat "." ((length(elemAt l i) - (length e)))))])  |> filter (e: e != [])) ++ (lib.drop (i + 1) l) ++ [(repeat "." (length e))]
;


placePart2 = l: e: i:
(lib.take i l) ++( ([e] ++ [( (repeat "." ((length(elemAt l i) - (length e)))))])  |> filter (e: e != [])) ++ (lib.drop (i + 1) l) ++ [(repeat "." (length e))]
|> trace "placed ${toString (head e)} to Position ${toString i} of ${toString (length l)}"
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

placefold = l:
foldl' (acc: curr:
let
  len = length acc.l;
  currentindex = len - curr - 1
    #|> trace "i = ${toString curr} index = ${toString (len - curr - 1)}"
    ;
  toPlace = elemAt acc.l currentindex;
  firstSearchBegin = acc.h."${toString (length toPlace)}";
  i = firstFitrec (lib.take currentindex acc.l |> lib.drop firstSearchBegin) (length toPlace) firstSearchBegin
   #|> trace "skipped ${toString acc.h.${toString (length toPlace)}} iterations"
  ;
  
in
  if currentindex <= 0 then acc else
  if toPlace == [] then acc else
  if head toPlace == "." then acc else
  if i == null then acc else
  if i >= currentindex then acc else
  {l = (placePart2 (lib.take currentindex acc.l) toPlace i) ++ (lib.drop (inc currentindex) acc.l);
    h = acc.h // { "${toString (length toPlace)}" = i - 1;};
  }

) {inherit l; h = {
  "1" = 0;
  "2" = 0;
  "3" = 0;
  "4" = 0;
  "5" = 0;
  "6" = 0;
  "7" = 0;
  "8" = 0;
  "9" = 0;
};} (lib.range 0 (length l))
|> (e: e.l)
|> (e: trace "blockGruppen: ${toString (length e)}" e)
;

part1 =
(checksum 0 10000) +
(checksum 10000 20000) +
(checksum 20000 30000) +
(checksum 30000 40000) +
(checksum 40000 totalUsedBlocs);

part2blocks = placefold blockgroups
  |> flat
  |> (e: trace "blocks: ${toString (length e)}" e)
  ;

checksumPart2 = start: size: part2blocks
  |> lib.drop start
  |> lib.take size
  |> foldl' (acc: curr: if curr == "." then {i = inc acc.i; value = acc.value;} else {i = inc acc.i; value = acc.value + (acc.i * curr);}) {i = start; value = 0;}
  |> (e: e.value)
  |> (e: trace "checksumteil: ${toString e}" e)
;

part2 = 
  (checksumPart2 0 10000) +
  (checksumPart2 10000 10000) +
  (checksumPart2 20000 10000) +
  (checksumPart2 30000 10000) +
  (checksumPart2 40000 10000) +
  (checksumPart2 50000 10000) +
  (checksumPart2 60000 10000) +
  (checksumPart2 70000 10000) +
  (checksumPart2 80000 10000) +
  (checksumPart2 90000 10000)
  #(checksumPart2 10000 10000).value +
  #(checksumPart2 20000 10000).value +

;
in
{ inherit part1 part2; }
  