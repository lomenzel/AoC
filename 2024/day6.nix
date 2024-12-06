with builtins; let 
  lib = (import <nixos> {}).lib;

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;
  input = readFile ./day6.input
    |> lib.splitString "\n"
    |> map lib.stringToCharacters
    ;

  inside =  x: y:
    x >= 0 && y >= 0 && x < (input |> head |> length) && y < length input;

  charAt = position:  if !inside position.x position.y then null else 
    elemAt (elemAt input position.y) position.x;

  charAtModified = m: position:  if !inside position.x position.y then null else 
    elemAt (elemAt m position.y) position.x;

  visit = position: visited:
    (lib.take position.y visited) ++ [(visitRow (elemAt visited position.y) position.x)] ++ (lib.drop (position.y + 1) visited);

  visitRow = row: x:
    (lib.take x row) ++ ["X"] ++ (lib.drop (x + 1) row);

  placeObsticle = position:
    (lib.take position.y input) ++ [(placeObsticleRow (elemAt input position.y) position.x)] ++ (lib.drop (position.y + 1) input);

  placeObsticleRow = row: x:
    (lib.take x row) ++ ["#"] ++ (lib.drop (x + 1) row);

 
  walk = position: visited:
    if ! inside position.x position.y then visited else
    walk (
      if charAt (step position) == "#" then turn position else step position
    ) (visit position visited);
    
  turn = position: position // {direction = lib.mod (position.direction + 1) 4;};

  step = position: if position.direction == 0 then
    position // {y = position.y - 1;} else if position.direction == 1 then
    position // {x = position.x + 1;} else if position.direction == 2 then
    position // {y = position.y + 1;} else if position.direction == 3 then
    position // {x = position.x - 1;} else throw "Illigal direction ${toString position.direction}";

  isCyclus = position: visited: m:
    if hasAttr (stringify position) visited then true else
    if ! inside position.x position.y then false else
    isCyclus (
      if (charAtModified m) (step position) == "#" then turn position else step position
    ) (visited // { "${stringify position}" = true;}) m;

  stringify = position: "${toString position.x}x${toString position.y}x${toString position.direction}";

  startPosition = lib.cartesianProductOfSets {x = lib.range 0 (input |> head |> length |> (e: e - 1)); y = lib.range 0 ((length input) - 1);}
    |> filter (e: charAt e == "^")
    |> head
    |> (e: e // {direction = 0;})
    ;

  defaultWalkPath = walk startPosition input;

  "Part 1" = defaultWalkPath
    |> map (filter (e: e == "X"))
    |> map length
    |> sum
    ;

  "Part 2" = lib.cartesianProductOfSets {x = lib.range 0 (input |> head |> length |> (e: e - 1)); y = lib.range 0 ((length input) - 1);}
    |> filter (e: charAtModified defaultWalkPath e == "X")
    |> map placeObsticle
    |> filter (e: (isCyclus startPosition {} e))
    |> length
    ;
in 
  {inherit "Part 1" "Part 2";}
