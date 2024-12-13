with builtins; let
  lib = (import <nixos> { }).lib;

  sum = list: foldl'(acc: curr: acc + curr) 0 list;
  product = list: foldl' (acc: curr: acc * curr) 1 list;
  concat = list: foldl' (acc: curr: acc + curr) "" list;
  join = separator: list: list
    |> map (e: e + separator)
    |> concat;
  flat = list: foldl' (acc: curr: acc ++ curr) [ ] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [ ] else [ e ] ++ repeat e (n - 1);
  odd = n: ! even n;
  input = readFile ./day12.input
    |> lib.splitString "\n"
    |> map (lib.splitString "")
    |> map (filter (e: e != ""))
    |> filter (e: e != [])
    |> wrap
    ;


  wrap = m:
    let 
      blank = repeat "." (m |> head |> length |> (e: e + 2));
    in [blank] ++ (map (e: ["."] ++ e ++ ["."]) m) ++ [blank];

  inside =  pos:
  with pos;
    x >= 0 && y >= 0 && x < (input |> head |> length) && y < length input;

  directionDeltas = [
    {
      x = 1;
      y = 0;
    }
    {
      x = -1;
      y = 0;
    }
    {
      x = 0;
      y = 1;
    }
    {
      x = 0;
      y = -1;
    }
  ];
  allCoords = lib.cartesianProductOfSets {x = lib.range 0 (input |> head |> length |> (e: e - 1)); y =  lib.range 0 (length input |> (e: e - 1));};
  atCoord = m: pos:
    elemAt (elemAt m pos.y) pos.x;

  nachbarn = pos:  
    map (f: {
      x = pos.x + f.x;
      y = pos.y + f.y;
    }) directionDeltas
    |> filter inside
    ;

  nachbarnByDirection = pos:
      map (f: {
      x = pos.x + f.x;
      y = pos.y + f.y;
    }) directionDeltas;


  print = m: m
    |> trace (repeat "-" (length (head m)) |> concat)
    |> map (e: trace (concat e) e)
    |> map (e: e)
    ;

  visit = position: visited:
    (lib.take position.y visited) ++ [(visitRow (elemAt visited position.y) position.x)] ++ (lib.drop (position.y + 1) visited);

  visitRow = row: x:
    (lib.take x row) ++ ["."] ++ (lib.drop (x + 1) row);

  calcRegion = m: pos:
  let
    positions = region [pos];
    perimeter = (area * 4) -
    (lib.cartesianProductOfSets {a = positions; b = positions;}
      |> filter isNachbar
      |> length);
    area = length positions;
    replaced = foldl' (acc: curr: visit curr acc) m positions;
  in
    {price = area * perimeter; m = replaced;}
    ;

  calcRegionPart2 = m: pos:
  let
    positions = region [pos];
    sides = calcSides pos;
    area = length positions ; 
    replaced = foldl' (acc: curr: visit curr acc) m positions;
  in
    {price = area * sides; m = replaced;}
    ;

  sidePairs = pos:
    let 
      positions = region [pos];
    in
      lib.cartesianProductOfSets {inside = positions; outside = outsideBorders pos ;};


  outsideBordersByDirection = pos:
  let positions = region [pos];
    nachbarmap = map nachbarnByDirection positions;
  in
  (lib.range 0 3)
    |> map (e: map (f: elemAt f e) nachbarmap)
    |> map (filter (e: atCoord input pos != atCoord input e))
    ;


  calcSides = pos: outsideBordersByDirection pos
    |> map (d: d
      #|> (e: trace "positions left ${toString (length e)}" e)
      |> foldl' (acc: curr: fill acc curr) emptyMap
      #|> (e: print e)
      |> (e: countGroups e)
      #|> (e: trace "found groups ${toString e}" e)
    )
    |> sum
    #|> (e: trace "found sides: ${toString e}" e)
    ;

  emptyMap = repeat (repeat "." (input |> head |> length)) (input |> length);

  fill = m: position:
    (lib.take position.y m) ++ [(fillRow (elemAt m position.y) position.x)] ++ (lib.drop (position.y + 1) m);

  fillRow = row: x:
    (lib.take x row) ++ ["X"] ++ (lib.drop (x + 1) row);

  region = pos:
  let
    plant =
    #trace "plant: ${toString (atCoord input (head pos))} size = ${toString (length pos)}"
     (atCoord input (head pos));
  in
   pos
    |> map nachbarn
    |> flat
    |> (e: e ++ pos)
    |> lib.lists.unique
    |> filter (e: atCoord input e == plant)
    |> (e: if length e == length pos then e else region e)
    ;


  regionPart2 = m: pos:
  let
    plant =
    #trace "plant: ${toString (atCoord input (head pos))} size = ${toString (length pos)}"
     (atCoord m (head pos));
  in
   pos
    |> map nachbarn
    |> flat
    |> (e: e ++ pos)
    |> lib.lists.unique
    |> filter (e: atCoord m e == plant)
    |> (e: if length e == length pos then e else regionPart2 m e)
    ;


  part1 = (foldl' (acc: curr:
  let
    m = 
    #print 
    acc.m;
    r = calcRegion m curr;
  in
    if atCoord m curr == "." then acc else
    {m = r.m; cost = acc.cost + r.price;}
  ) {m = input; cost = 0;} allCoords)
    |> (e: e.cost)
    ;


  countGroups = m: allCoords
    |> foldl' (acc: curr:
      let
        m = acc.m;
        replaced = foldl' (acc: curr: visit curr acc) m (regionPart2 m [curr]);
      in
        if atCoord m curr == "." then acc else
        {m = replaced; cost = inc acc.cost;}
      ) {inherit m; cost = 0;}
    |> (e: e.cost)
    ;

  part2 = allCoords
    |> foldl' (acc: curr:
      let
        m = 
        #print 
        acc.m;
        r = calcRegionPart2 m curr;
      in
        if atCoord m curr == "." then acc else
        {m = r.m; cost = acc.cost + r.price;}
      ) {m = input; cost = 0;} 
    |> (e: e.cost)
    ;



in
{ inherit part1 part2; }