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
      in
        [
          {
            cost = 1000;
            state = Maze' maze.original maze.position left;
          }
          {
            cost = 1000;
            state = Maze' maze.original maze.position right;
          }
        ]
        ++ (if stepPossible then [{
          cost = 1;
          state = Maze' maze.original forward maze.direction;
        }] else []);
    in rec {
      inherit original position direction;
      self = {inherit original next position self direction goal reached heuristik equals; };
      goal = original.find "E";
      reached = position == goal;
      next = calcNext self;
      heuristik = manhattanDistance position goal;
      equals = othermaze: position == othermaze.position && direction == othermaze.direction;
    };
  Maze = initialState:
  let 
    original = grid.fromString initialState;
  in Maze' original (original.find "S") (vecToCoord [1 0]);
 
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


in
  #{ inherit part1 part2 tests; }
(aStar (Maze realinput)).pathCost
#(Maze testinput3).next |> head |> (e: e.state.reached)