with builtins; with (import ../lib.nix); let

  realinput = readFile ./day15.input;

  testinput1 =  ''
    ##########
    #..O..O.O#
    #......O.#
    #.OO..O.O#
    #..O@..O.#
    #O#..O...#
    #O..O..O.#
    #.OO.O.OO#
    #....O...#
    ##########

    <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
  '';

  testinput2 = ''
    ########
    #..O.O.#
    ##@.O..#
    #...O..#
    #.#.O..#
    #...O..#
    #......#
    ########

    <^^>>>vv<v>>v<<
  '';

  testinput3 = ''
    #####
    #...#
    #..O#
    #..O#
    #.O@#
    #####

    <
  '';

  parseInput = input: input
    |> lib.splitString "\n\n"
    |> filter (e: e != "")
    |> (e: {
      warehouse = Warehouse (head e);
      moves = (elemAt e 1) 
        |> lib.splitString ""
        |> filter (f: f != "")
        |> filter (f: f != "\n")
        |> filter (f: f != " ")
        |> map (f:
          if f == "^" then vecToCoord [0 (-1)] else
          if f == ">" then vecToCoord [1 0] else
          if f == "<" then vecToCoord [(-1) 0] else
          if f == "v" then vecToCoord [0 1] else
          abort "unknown direction ${toString f}"
        );
    })
    ;

  parseInputForPart2 = input: input
    |> parseInput
    |> (p1: {
      moves = p1.moves;
      warehouse = Warehouse (p1.warehouse.state.state |> map (e:
        map (f: 
          if f == "." then ["." "."] else
          if f == "#" then ["#" "#"] else
          if f == "O" then [ "[" "]"] else
          if f == "@" then [ "@" "."] else
          abort "huch ${f}"
        ) e |> flat
      ) |> grid.init );
    });

  Warehouse = initialState:
     rec {
        state = if isString initialState then grid.fromString initialState else initialState;
        robot = state.find "@";
        print = s: Warehouse (state.print "Warehouse: ${s}");
        gps = foldl' (acc: curr: 
          if state.get curr == "O" || state.get curr == "[" then acc + (100 * curr.y + curr.x) else acc) 0 state.allCoords;
        moveRobot = direction:
          let
            target = addPos robot direction;
            l = addPos target (vecToCoord [(-1) 0]);
            r = addPos target (vecToCoord [1 0]);
            char = state.get target;
          in

            # movement part1
            if char == "." then
              (state.set "@" target).set "." robot |> Warehouse# |> (e: e.print "moved robot")
              else
            if char == "#" then
              Warehouse state else
            if char == "O" && boxIsMovable target direction then
              (moveBox target direction).moveRobot direction else
            if char == "O" && !boxIsMovable target direction then
              Warehouse state else


            # large box in front of robot
            if direction.x == 0 then (
              # move v or ^
              if char == "[" && largeBoxIsMovable target direction then 
                (moveLargeBox target direction).moveRobot direction else 
              if char == "]" && largeBoxIsMovable l direction then
                (moveLargeBox l direction).moveRobot direction else
              Warehouse state 
            ) else (
              # move < or >
              if largeBoxIsMovable target direction then 
                (moveLargeBox target direction).moveRobot direction else
              Warehouse state
            );
            #abort "something went Wrong ${(print "Illegal Characters ").state.get target}";

        moveLargeBox = box: direction: 
          let 
            targetL = addPos box direction;
            r = {y = box.y; x = box.x + 1;};
            targetR = addPos r direction;
            charL = state.get targetL;
            charR = state.get targetR;
            originalCharL = state.get box;
            originalCharR = state.get r;
          in
          if direction.x == 0 then (
            # move ^ or v
            if charL == "." && charR == "." then
              (((state.set originalCharL targetL).set originalCharR targetR).set "." box).set "." r |> Warehouse
              else
            if charL == "[" then
              (moveLargeBox targetL direction).moveLargeBox box direction else
            if charL == "]" && charR == "[" then
              ((moveLargeBox targetR direction).moveLargeBox {x = targetL.x - 1; y = targetL.y;} direction).moveLargeBox box direction else
            if charL == "]" then
              (moveLargeBox {x = targetL.x - 1; y = targetL.y;} direction).moveLargeBox box direction else
            if charR == "[" then
              (moveLargeBox targetR direction).moveLargeBox box direction
            else
            abort "something went Wrong ${(print "Illegal Characters ").state.get targetL}"

          ) else (
            # move < or >
              if charL == "." then 
                (state.set originalCharL targetL).set "." box |> Warehouse else
              (moveLargeBox targetL direction).moveLargeBox box direction
          );


        largeBoxIsMovable = box: direction: 
          let
            targetL = addPos box direction;
            r = { y = box.y; x = box.x + 1;};
            targetR = addPos r direction;
            charL = state.get targetL;
            charR = state.get targetR;
          in
          if direction.x == 0 then (
            # move ^ or v
            if charL == "#" || charR == "#" then false else
            if charL == "." && charR == "." then true else
            if charL == "["  then
              largeBoxIsMovable targetL direction else
            if charL == "]" && charR == "." then
              largeBoxIsMovable {y = targetL.y; x = targetL.x - 1;} direction else
            if charL == "." && charR == "[" then
              largeBoxIsMovable targetR direction else
            if charL == "]" && charR == "[" then
              largeBoxIsMovable {y = targetL.y; x = targetL.x - 1;} direction  && largeBoxIsMovable targetR direction else 
            abort "something went Wrong ${(print "Illegal Characters ").state.get targetL}"


          ) else (
            # move < or >
            if charL == "." then true else
            if charL == "#" then false else
            largeBoxIsMovable targetL direction
          )
          ;

        moveBox = box: direction:
          let 
            target = addPos box direction;
            char = state.get target;
          in 
            if char == "." then 
              (state.set "O" target).set "." box |> Warehouse else
            if char == "#" then
              abort "do not try to move a box into a wall :) ${(print ":(").state.get target}" else
            if char == "O" then
              moveBox target direction else
            abort "something went Wrong ${(print "Illegal Characters ").state.get target}";

        boxIsMovable = box: direction: 
          let
            target = addPos box direction;
            char = state.get target;
          in
            if char == "." then true else
            if char == "#" then false else
            if char == "O" then boxIsMovable target direction else
            abort "something went Wrong ${(print "Illegal Characters ").state.get target}";
     };


  simulate = input: with input;
    ((foldl' (wh: wh.moveRobot) warehouse moves).print "Finish ").gps;

  part1 = input: simulate (parseInput input);
  part2 = input: simulate (parseInputForPart2 input);



  tests = {
    part1 = [{
      input = testinput1;
      expected = 10092;
    } {
      input = testinput2;
      expected = 2028;
    } {
      input = testinput3;
      expected = 101;
    }];
    part2 = [{
      input = testinput1;
      expected = 9021;
    }];
  };

in
 # { inherit part1 part2 tests; }

part2 realinput