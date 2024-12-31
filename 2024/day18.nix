with builtins; with (import ../lib.nix); let
  realinput = readFile ./day18.input;

  parseInput = input: let
      meta = lib.splitString "\n\n" input |> head;
      falling = lib.splitString "\n\n" input |> (e: elemAt e 1) 
        |> lib.splitString "\n"
        |> filter (e: e != "")
        |> map (e: lib.splitString "," e |> map lib.toInt)
        |> map vecToCoord
        ;
      size = lib.splitString "," meta |> head |> lib.toInt;
      n = lib.splitString "," meta |> (e: elemAt e 1) |> lib.toInt;
    in
      {
        part1 = Maze (foldl' (acc: acc.set "#") (grid.empty "." {x = size; y= size;}) (lib.take n falling));
        part2 = {inherit size falling;};
      };

  Maze' = original: position:
      let 
      calcNext = maze:
        maze.original.adjacent maze.position |> filter (e: maze.original.get e != "#") |>  map (Maze' maze.original) |> map (e: {state = e; cost = 1;});
      
      in rec {
        inherit original position;
        self = {inherit original next position self direction goal reached heuristik toString; };
        goal = {x = original.width - 1; y = original.height - 1;};
        reached = position == goal;
        next = calcNext self;
        heuristik = (manhattanDistance position goal);
        toString = "${builtins.toString position.x}x${builtins.toString position.y}";
      };
  Maze = initialState:
    let 
      original = initialState;
    in Maze' original {x = 0; y = 0;};

  part1 = input: (aStar (parseInput input).part1).pathCost;

  solvable = input: n: 
    let 
      maze = Maze (foldl' (acc: acc.set "#") (grid.empty "." {x = input.size; y= input.size;}) (lib.take n input.falling));
    in  
      aStar maze != null;

  firstUnsolvable = input: lower: upper:
    let 
      n = lower + ((upper - lower) / 2);
      curr = solvable input n;
      next = solvable input (n + 1);
    in
      if curr && ! next then n else
      if curr && next then firstUnsolvable input n upper else
      if ! curr && ! next then firstUnsolvable input lower n else
      abort "it somehow got solvable again";
    
  part2 = input:
    let 
      i = (parseInput input).part2;
      n = firstUnsolvable i 0 (length i.falling);
    in
      elemAt i.falling n;

in
  {inherit part1 part2;}