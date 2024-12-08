with builtins; let 
  lib = (import <nixos> {}).lib;

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;
  flat = list: lib.fold (curr: acc: acc ++ curr) [] list;
  input = readFile ./day8.input 
    |> lib.splitString "\n"
    |> map (f: lib.splitString "" f |> filter (e: e != ""))
    ;

  inside =  x: y:
    x >= 0 && y >= 0 && x < (input |> head |> length) && y < length input;

  charAt = position:  if !inside position.x position.y then null else 
    elemAt (elemAt input position.y) position.x;

  allCoords = lib.cartesianProductOfSets {x = lib.range 0 (input |> head |> length |> (e: e - 1)); y =  lib.range 0 (length input |> (e: e - 1));};

  antinodes = pos1: pos2:
    if pos1 == pos2 then [] else
    [
      {
        x = pos1.x - (pos2.x - pos1.x);
        y = pos1.y - (pos2.y - pos1.y);
      } {
        x = pos2.x + (pos2.x - pos1.x);
        y = pos2.y + (pos2.y - pos1.y);
      }
    ];

  posPairs = pos:
    lib.cartesianProductOfSets {pos1 = pos; pos2 = pos;};

  recAntinodes = pos:
    let 
      withAntinodes = pos ++ (posPairs pos
        |> map (e: antinodes e.pos1 e.pos2)
        |> flat
      )
      |> lib.lists.unique
      |> filter (e: inside e.x e.y)
      ;
    in
    if withAntinodes == pos then withAntinodes else
    recAntinodes withAntinodes;

  part1 = groupBy charAt allCoords
    |> lib.attrsToList
    |> filter (e: e.name != ".")
    |> map (e: e.value)
    |> map posPairs
    |> map (f: map (e: antinodes e.pos1 e.pos2) f)
    |> map flat
    |> flat
    |> lib.lists.unique
    |> filter (e: inside e.x e.y)
    |> length
    ;
  part2 = groupBy charAt allCoords
    |> lib.attrsToList
    |> filter (e: e.name != ".")
    |> map (e: e.value)
    |> map posPairs
    |> map (e: map (f: recAntinodes [f.pos1 f.pos2]) e)
    |> map flat
    |> flat
    |> lib.lists.unique 
    |> length
    ;
in
  {"Part 1" = part1; "Part 2" = part2;}