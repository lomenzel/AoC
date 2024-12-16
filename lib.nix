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

    # l = [number number] -> {x = number; y = number;}
  vecToCoord =  l:
    {
      x = head l;
      y = elemAt l 1;
    };


  modPositive = base: int: lib.mod base int |> (e: e + int) |> (e:  lib.mod e  int);

  abs = a: lib.max a (-a);

  manhattanDistance = pos1: pos2:
    (abs (pos1.x - pos2.x)) + (abs (pos1.y - pos2.y));


  # Parameter:
  #   start is a Node of the SearchGraph. it should contain at least the attributes:
  #     heuristik: a Number representing the heuristik used by A*
  #     next: a list of AttributeSets containing 
  #       cost: the cost it takes to follow that edge
  #       state: a state, similar to start (yes that also should have next, equals etc...)
  #     reached: a boolean if the state should be accepted as a result
  #     equals: a function of state -> boolean. if the state given as parameter equals this state
  # Returns: A SearchTree Node with the following structure
  # {
  #   state: the state of the Search Graph A* has found
  #   cost: cost of the last step
  #   pathCost: cost it takes to walk from start to the returned state
  #   self: the return value itself
  #   expand: all SearchTree Nodes Reachable from this SearchTree Node
  #   parent: the parent of this SearchTreeNode
  # }
  # or null if none of the Nodes of the SearchGraph has the reached attribute of true
  aStar = start:
    let
      sortBorder = sort (a: b: a.state.heuristik + a.pathCost < b.state.heuristik + b.pathCost);
      stateToNode = p: c: s: rec {
        state = s;
        parent = p;
        cost = c;
        self = { inherit cost state parent expand self pathCost; };
        expand = state.next
          |> map (e: stateToNode self e.cost e.state);
        pathCost = if parent == null then cost else cost + parent.pathCost;
      };
      aStar' = reached: border:
        let
          node =
            trace "bordersize: ${toString (length border)}; pathCost: ${toString (head border).pathCost}; heuristik ${toString (head border).state.heuristik}" #; reached ${toString (length reached)}"
           (head border);
        in
          if border == [] then null else
          if node.state.reached then node else
          (tail border) ++ (node.expand |> filter (e: ! hasAttr e.state.toString reached)) |> sortBorder |> aStar' (reached // { "${node.state.toString}" = true; });
    in
      aStar' {} [(stateToNode null 0 start)];

  grid = rec {
    fromString = s: s
      |> lib.splitString "\n"
      |> filter (e: e != "")
      |> map (lib.splitString "")
      |> map (filter (e: e != ""))
      |> filter (e: e != [])
      |> init;

    init = g: rec {
        state = g;
        width = state |> head |> length;
        height = state |> length;
        get = pos:
          elemAt (elemAt state pos.y) pos.x;
        find = char:
          let
            l = flat state;
            i = lib.lists.findFirstIndex (e: e == char) (-1) l;
          in
            vecToCoord [
              (lib.mod i width)
              (div i width)
            ];
        set = value: pos: 
          let
              visit = position: value:
                (lib.take position.y state) ++ [(visitRow (elemAt state position.y) position.x value)] ++ (lib.drop (position.y + 1) state);

              visitRow = row: x: value:
                (lib.take x row) ++ [value] ++ (lib.drop (x + 1) row);
          in
          init (visit pos value);
        wrap = char:
          let 
            blank = repeat char (m |> head |> length |> (e: e + 2));
          in init ([blank] ++ (map (e: [char] ++ e ++ [char]) m) ++ [blank]);

        print = s: state
          |> trace s
          |> map (e: trace (concat e) e)
          |> map (e: e)
          |> init;
        allCoords = lib.cartesianProductOfSets {x = lib.range 0 (state |> head |> length |> (e: e - 1)); y =  lib.range 0 (length state |> (e: e - 1));};

      };
  };


    # pos1 = Position; pos2 = Position; -> Position
  addPos = pos1: pos2:
    { 
      x = pos1.x + pos2.x;
      y = pos1.y + pos2.y;
    };

  # pos = Position; n = number; -> Position
  mulPos = pos: n:
    {
      x = pos.x * n;
      y = pos.y * n;
    };

}