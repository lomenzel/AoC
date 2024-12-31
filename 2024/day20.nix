with builtins; with (import ../lib.nix); let
  realinput = readFile ./day20.input;

  testinput = ''
    ###############
    #...#...#.....#
    #.#.#.#.#.###.#
    #S#...#.#.#...#
    #######.#.#.###
    #######.#.#...#
    #######.#.###.#
    ###..E#...#...#
    ###.#######.###
    #...###...#...#
    #.#####.#.###.#
    #.#...#.#.#...#
    #.#.#.#.#.#.###
    #...#...#...###
    ###############
  '';

  parseInput = input: input
    |> lib.splitString "\n"
    |> filter (e: e != "")
    |> map (lib.splitString "")
    |> map (filter (e: e != ""))
    |> grid.init
  ;

  Maze' = original: forbiddenCheats: usedCheat: cheatedPositions: position:
      let 
      calcNext = maze: 
        if maze.usedCheat && length cheatedPositions == 2 then
          maze.original.adjacent maze.position 
            |> filter (e: maze.original.get e != "#") 
            |> map (Maze' maze.original forbiddenCheats maze.usedCheat maze.cheatedPositions) 
            |> map (e: {state = e; cost = 1;}) else
        if maze.usedCheat && length maze.cheatedPositions == 1 then
          maze.original.adjacent maze.position 
            # everything is allowed when cheating except allready used cheats
            |> filter (e: maze.original.get e != "#") 
            |> filter (pos: ! any (curr: (head curr == position && elemAt curr 1 == pos)) forbiddenCheats)
            |> map (pos: Maze' maze.original forbiddenCheats maze.usedCheat (maze.cheatedPositions ++ [pos]) pos) 

            |> map (e: {state = e; cost = 1;}) else
        if !maze.usedCheat then
          #everything normal
          (maze.original.adjacent maze.position 
            |> filter (e: maze.original.get e != "#") 
            |> map (Maze' maze.original forbiddenCheats maze.usedCheat maze.cheatedPositions) 
            |> map (e: {state = e; cost = 1;}))
          ++
          # startCheat
          (maze.original.adjacent maze.position 
            |> filter (e: maze.original.get e == "#") 
            |> map (pos: Maze' maze.original forbiddenCheats true (maze.cheatedPositions ++ [pos]) pos) 
            |> map (e: {state = e; cost = 1;})) else
        abort "illegal State Exception";
      
      in rec {
        inherit original position cheatedPositions usedCheat;
      
        self = {inherit original next position cheatedPositions self usedCheat direction goal reached heuristik toString; };
        goal = original.find "E";
        reached = position == goal;
        next = calcNext self;
        heuristik = (manhattanDistance position goal);
        toString = "${builtins.toString position.x}x${builtins.toString position.y}x${builtins.toString usedCheat}";
      };
  Maze = initialState: forbiddenCheats:
    let 
      original = initialState;
    in Maze' original forbiddenCheats false [] (original.find "S");

  fastestPathWithoutCheats = g: 
    (aStar (Maze' g [] true ["nooneCares" "still dont care"] (g.find "S")));


  generateCache' = curr: prev: cache:
    let 
      id = curr.state.toString;
      oldId = prev.state.toString;
    in
      if prev == null then 
       generateCache' curr.parent curr (cache // { "${id}" = 0; }) else
      if curr == null then cache else
      generateCache' curr.parent curr (cache // { "${id}" = cache.${oldId} + (lib.max curr.cost 1);});

  generateCache = g:
    generateCache' (fastestPathWithoutCheats g) null {};

  
  doubleDirection = directionDeltas
    |> map (pos: addPos pos pos);




  idToPos = id: {x = elemAt (lib.splitString "x" id) 0 |> lib.toInt; y = elemAt (lib.splitString "x" id) 1 |> lib.toInt;};

  posToId = pos: "${toString pos.x}x${toString pos.y}x1";

  helpfulCheats = g:
    let 
      cache = generateCache g;
    in
      cache
      |> lib.attrsToList
      |> map (e: e.name)
      |> map (e: map (cheat:
          if ! hasAttr cheat cache then false else
          if cache.${cheat} < (cache.${e} - 101) then true else false
        ) (cheatedPositions e) |> map (f: if f then 1 else 0) |> sum)
      #|> filter (e: e > 0)
      |> sum
      ;

  allCoordsWithMaxDistance = pos: n:
    lib.cartesianProductOfSets {x = lib.range (-n) (n); y = lib.range (-n)  n;}
    |> map (e: addPos pos e)
    |> filter (e: manhattanDistance e pos <= n)
    |> lib.unique;

  helpfulCheatsN = g: n:
    let 
      cache' = generateCache g;
      cache = trace "cache Generated ${lib.attrsToList cache' |> length |> toString}" cache';
    in
      cache
      |> lib.attrsToList
      |> map (e: e.name)
      |> map (e: map (cheat:
          hasAttr cheat cache &&
          cache.${cheat} <= (cache.${e} - 100 - (manhattanDistance (idToPos cheat) (idToPos e)))
        ) ([e] |> map (f: allCoordsWithMaxDistance (idToPos f) n) |> flat |> map posToId) |> map (f: if f then 1 else 0) |> sum)
      |> sum
      ;

    cheatedPositionsP2 = id: directionDeltas
    |> map (dir: addPos (idToPos id) dir)
    |> map (posToId);

    part1 = input:
      helpfulCheatsN (parseInput input) 2;

    part2 = input:
      helpfulCheatsN (parseInput input) 20;


in
  { inherit part1 part2; }