with builtins; with (import ../lib.nix); let
  realinput = readFile ./day16.input;

  testinput1 = ''
    ###############
    #.......#....E#
    #.#.###.#.###.#
    #.....#.#...#.#
    #.###.#####.#.#
    #.#.#.......#.#
    #.#.#####.###.#
    #...........#.#
    ###.#.#####.#.#
    #...#.....#.#.#
    #.#.#.###.#.#.#
    #.....#...#.#.#
    #.###.#.#.#.#.#
    #S..#.....#...#
    ###############
  '';

  testinput2 = ''
    #################
    #...#...#...#..E#
    #.#.#.#.#.#.#.#.#
    #.#.#.#...#...#.#
    #.#.#.#.###.#.#.#
    #...#.#.#.....#.#
    #.#.#.#.#.#####.#
    #.#...#.#.#.....#
    #.#.#####.#.###.#
    #.#.#.......#...#
    #.#.###.#####.###
    #.#.#...#.....#.#
    #.#.#.#####.###.#
    #.#.#.........#.#
    #.#.#.#########.#
    #S#.............#
    #################
  '';

  testinput3 = ''
    ####
    #E.#
    #S.#
    ####
  '';

  tests = {
    part1 = [{
        input = testinput1;
        expected = 7036;
      } {
        input = testinput2;
        expected = 11048;
      }];

  };

  Maze' = original: position: direction:
    let 
    calcNext = maze:
      let
        directionIndex = lib.lists.findFirstIndex (e: e == maze.direction) (-1) directionDeltas;
        left = elemAt directionDeltas (modPositive (directionIndex - 1) 4);
        right = elemAt directionDeltas (modPositive (directionIndex + 1) 4);
        forward = addPos maze.position maze.direction;
        stepPossible = (maze.original.get forward) == "." || (maze.original.get forward) == "E";
        charLeft = maze.original.get (addPos maze.position left);
        charRight = maze.original.get (addPos maze.position right);
        possibleEdges = ( if charLeft != "#" then [
          {
            cost = 1000;
            state = Maze' maze.original maze.position left;
          }] else [])
        ++ ( if charRight != "#" then [{
            cost = 1000;
            state = Maze' maze.original maze.position right;
          }
        ] else [])
        ++ (if stepPossible then [{
          cost = 1;
          state = Maze' maze.original forward maze.direction;
        }] else []);
    in
      #if length possibleEdges == 1 && ! (head possibleEdges).state.reached then
      # (head possibleEdges).state.next |> map (e: e // { cost = e.cost + (head possibleEdges).cost;}) else
      possibleEdges
        ;
    in rec {
      inherit original position direction;
      self = {inherit original next position self direction goal reached heuristik equals; };
      goal = original.find "E";
      reached = position == goal;
      next = calcNext self;
      heuristik = (manhattanDistance position goal) + ( if position.x != goal.x && position.y != goal.y  then 1000 else 0);
        #0;
      #equals = othermaze: position == othermaze.position && direction == othermaze.direction;
      toString = "${builtins.toString position.x}x${builtins.toString position.y}x${builtins.toString direction.x}x${builtins.toString direction.y}";
    };
  Maze = initialState:
  let 
    original = grid.fromString initialState;
  in Maze' original (original.find "S") (vecToCoord [1 0]);


  allReachedToVeryCoolFinalNodes = goal: reached:
     (foldl' (acc: curr:
      let
        str = "${toString goal.x}x${toString goal.y}x${toString curr.x}x${toString curr.y}";
      in
        if hasAttr str reached then acc ++ [reached.${str}] else acc
     ) [] directionDeltas)
     |> sort (a: b: a.pathCost < b.pathCost)
     |> (e:
        let 
          cheapestPathCost = (head e).pathCost;
        in
          filter (f: f.pathCost == cheapestPathCost) e
     )
     |> allReachedToVeryCoolFinalNodes' reached
     ;

  
 allReachedToVeryCoolFinalNodes' = reached: nodes:
  map (node:
    node.setParents (map (p:
      reached.${p.state.toString}
      ) node.parents |> allReachedToVeryCoolFinalNodes' reached)
  ) nodes;

 # Parameter:
  #   start is a Node of the SearchGraph. it should contain at least the attributes:
  #     heuristik: a Number representing the heuristik used by A*
  #     next: a list of AttributeSets containing 
  #       cost: the cost it takes to follow that edge
  #       state: a state, similar to start (yes that also should have next, equals etc...)
  #     reached: a boolean if the state should be accepted as a result
  #     toString: a minimal string representation used to keep track of what nodes are already expanded 
  # Returns: 
  # a set of all reached positions
  allBestPaths = start:
    let
      sortBorder = sort (a: b: a.state.heuristik + a.pathCost < b.state.heuristik + b.pathCost);
      stateToNode = p: c: s: rec {
        state = s;
        parents = p;
        cost = c;
        self = { inherit cost state parents expand self pathCost addParent setParents; };
        expand = state.next
          |> map (e: stateToNode [self] e.cost e.state);
        pathCost = if parents == [] then cost else cost + (head parents).pathCost;
        addParent = p: 
          let newParents = 
            trace  "parent Count: ${builtins.toString (length ([p] ++ parents))}; distinct parents: ${builtins.toString (lib.lists.unique (([p] ++ parents) |> map (e: e.state.toString)) |> length)}"
          ([p] ++ parents |> groupBy (e: e.state.toString) |> lib.attrsToList |> map (e: head e.value));
          in
          stateToNode newParents cost state;
        setParents = p: stateToNode (trace "set ${toString (length p)} parents" p) cost state;
      };
      aStar' = reached: border:
        let
          node =
           trace "bordersize: ${toString (length border)}; pathCost: ${toString (head border).pathCost}; heuristik ${toString (head border).state.heuristik}"
           (head border);
          children = node.expand;
          newBorder  = (filter (child: ! hasAttr child.state.toString reached) children) ++ (tail border) |> sortBorder;
          allreadyExpandedChildren = filter (child: hasAttr child.state.toString reached && reached.${child.state.toString}.pathCost >= child.pathCost) children;
          isNewNode = hasAttr node.state.toString reached;
          newReached = #if isNewNode then abort "trying to handle an already expanded node" else
           foldl' (acc: curr: acc // { "${curr.state.toString}" = acc.${curr.state.toString}.addParent node;}) reached allreadyExpandedChildren;
        in
          if border == [] then reached else
          if node.state.reached then aStar' (newReached // { "${node.state.toString}" = node; }) (tail border) else
          if  hasAttr node.state.toString newReached && node.pathCost < reached.${node.state.toString}.pathCost  then
            abort "??? currentCost = ${toString node.pathCost}; reachedPathCost = ${toString reached.${node.state.toString}.pathCost}" else
          if hasAttr node.state.toString newReached && node.pathCost > reached.${node.state.toString}.pathCost then
            aStar' reached (tail border) else
          if hasAttr node.state.toString newReached then
            aStar' (newReached // {"${node.state.toString}" = node.setParents (
              node.parents ++ 
              newReached.${node.state.toString}.parents
            );}) (tail border)
          else
            aStar' (newReached // { "${node.state.toString}" = node; }) newBorder;
    in
      aStar' {} [(stateToNode [] 0 start)];

  directionDeltas = [
    {
      x = 0;
      y = (-1);
    }
    {
      x = 1;
      y = 0;
    }
    {
      x = 0;
      y = 1;
    }
    {
      x = (-1);
      y = 0;
    }
  ];

  drawPath = m: node:
    foldl' drawPath (m.set "O" node.state.position) node.parents ;


  part1 = input: (aStar (Maze input)).pathCost;

  part2 = input: (allBestPaths (Maze input)) 
    |> allReachedToVeryCoolFinalNodes (Maze input).goal
    #|> (e: trace "${toString (length e)}" e)
    |> foldl' drawPath (Maze input).original
    |> (e: (e.print "final").state) 
    |> map (map (f: if f == "O" then 1 else 0)) 
    |> flat |> sum
    ;


in
  { inherit part1 part2 tests; }