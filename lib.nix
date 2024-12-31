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
  count = e: l: map (f: if  f == e  then 1 else 0) l |> sum;

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
  #       state: a state, similar to start (yes that also should have next, reached etc...)
  #     reached: a boolean if the state should be accepted as a result
  #     toString: a minimal string representation used to keep track of what nodes are already expanded 
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
          |> map (e: stateToNode self e.cost e.state)
          |> (e: if length e == 1 && ! (head e).state.reached then
              (head e).expand
            else e) 
            ;
        pathCost = if parent == null then cost else cost + parent.pathCost;
      };
      aStar' = reached: border:
        let
          node =
           #trace "bordersize: ${toString (length border)}; pathCost: ${toString (head border).pathCost}; heuristik ${toString (head border).state.heuristik}"
           (head border);
        in
          if border == [] then null else
          if node.state.reached then node else
          if hasAttr node.state.toString reached && node.pathCost >= reached.${node.state.toString} then aStar' reached (tail border) else
          (node.expand |> filter (e: ! hasAttr e.state.toString reached)) ++ (tail border) |> sortBorder |> aStar' (reached // { "${node.state.toString}" = node.pathCost; });
    in
      aStar' {} [(stateToNode null 0 start)];

  grid = rec {

    empty = char: dimensions: repeat (repeat char dimensions.x) dimensions.y |> init;


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
            i = lib.lists.findFirstIndex (e: e == char) (abort "not found") l;
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

        transpose = init (lib.range 0 (width - 1) |>
          map (x: lib.range 0 (height - 1)
            |> map (y: get {inherit x y ;} )
          )
        );

        rotate = init (lib.range 0 (width - 1)
          |> map (row: lib.range 0 (height -1)
            |> map (col:
              get {
                x = (width - 1 - row);
                y = col;
              }
            ))
        );

        countChar = c: map (count c) state |> sum;


        adjacent = pos:  
          map (f:
            {
              x = pos.x + f.x;
              y = pos.y + f.y;
            }
            ) directionDeltas
          |> filter isInside;

        isInside = pos: 
            pos.x < width && pos.x >= 0 && pos.y < height  && pos.y >= 0;

        wrap = char:
          let 
            blank = repeat char (m |> head |> length |> (e: e + 2));
          in init ([blank] ++ (map (e: [char] ++ e ++ [char]) m) ++ [blank]);

        print = trace "Grid:\n ${join "\n " (map concat state)}" (init state);
        allCoords = lib.cartesianProductOfSets {x = lib.range 0 (state |> head |> length |> (e: e - 1)); y =  lib.range 0 (length state |> (e: e - 1));};

      };
  };

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