with builtins; with (import ../lib.nix); let

    part1 = input: input |> parseInput |> safetyFactor 100;
    part2 = input: input |> parseInput |> christmasTree 0;


/* TYPES

 Robot = {
    position = Position
    velocity = Position
 }


*/

    # String ->{ bots = Robot[]; bathroomDimensions = Position;}
    parseInput = input: input
        |> lib.splitString "\n"
        |> filter (e: e != "")
        |> tail
        |> map (lib.splitString " ")
        |> map (filter (e: e != ""))
        |> map (map (e: split "(-?[0-9]+)" e |> filter (f: (!isString f)) |> flat |> map (lib.toInt)))
        |> map (robot:
            {
                position = vecToCoord (head robot);
                velocity = vecToCoord (elemAt robot 1);
            }
        )
        |> (e: {
            bots = e;
            bathroomDimensions = input
                |> lib.splitString "\n"
                |> filter (e: e != "")
                |> head
                |> lib.splitString " "
                |> filter (e: e != "")
                |> map (lib.toInt)
                |> vecToCoord;
        })
        ;

    realinput = readFile ./day14.input;


    testinput = ''
        11 7
        p=0,4 v=3,-3
        p=6,3 v=-1,-3
        p=10,3 v=-1,2
        p=2,0 v=2,-1
        p=0,0 v=1,3
        p=3,0 v=-2,-2
        p=7,6 v=-1,-3
        p=3,0 v=-1,-2
        p=9,3 v=2,3 
        p=7,3 v=-1,2
        p=2,4 v=2,-3
        p=9,5 v=-3,-3
    '';

    # robot = Robot; time = nummber; -> Position
    robopos = time: robot: addPos robot.position (mulPos robot.velocity time);


    modPos = dimensions: position:  {
                x = modPositive position.x (dimensions.x);
                y = modPositive position.y (dimensions.y);
            };

    modQuadrant = bathroomDimensions: position:
        let 
            pos = modPos bathroomDimensions position;
        in
            if pos.x < bathroomDimensions.x / 2 && pos.y < bathroomDimensions.y / 2 then "topLeft" else
            if pos.x < bathroomDimensions.x / 2 && pos.y > bathroomDimensions.y / 2 then "bottomLeft" else
            if pos.x > bathroomDimensions.x / 2 && pos.y < bathroomDimensions.y / 2 then "topRight" else
            if pos.x > bathroomDimensions.x / 2 && pos.y > bathroomDimensions.y / 2 then "bottomRight" else
            "middle"
            ;


    # situation = { bots = Robot[]; bathroomDimensions = Position;}; time = number -> number
    safetyFactor = time: situation:  situation.bots
        |> map (robopos time)
        |> lib.groupBy (modQuadrant situation.bathroomDimensions)
        |> mapAttrs (name: value: length value)
        |> lib.attrsToList
        |> filter (e: e.name != "middle")
        |> map (e: e.value)
        |> product
        ;

    mirrorY = m: all palindrome m;

    palindrome = word: word == lib.reverseList word;

    allCoords = m: lib.cartesianProductOfSets {x = lib.range 0 (m |> head |> length |> (e: e - 1)); y =  lib.range 0 (length m |> (e: e - 1));};

    countGroups = m: allCoords m
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


    christmasTree = n: situation:
        let 
            m = situation.bots |> map (robopos n) |> draw situation.bathroomDimensions;
            positions = situation.bots |> map (robopos n) |> map (modPos situation.bathroomDimensions);
            overlapping = length positions != length (lib.lists.unique positions);
        in
        if ! overlapping  then m |> printMap else christmasTree ((trace "${toString n}" n) + 1) situation
        ;

    # dimensions = Position -> "."[dimensions.y][dimensions.x]
    emptyMap = dimensions: repeat (repeat "." dimensions.x) dimensions.y;

    fill = m: position:
        (lib.take position.y m) ++ [(fillRow (elemAt m position.y) position.x)] ++ (lib.drop (position.y + 1) m);

    fillRow = row: x:
        (lib.take x row) ++ ["X"] ++ (lib.drop (x + 1) row);


    # positions = Position[]; dimensions = Position -> Map
    draw = dimensions: positions: positions
        |> map (modPos dimensions)
        |> foldl' fill (emptyMap dimensions)
        |> wrap;

    atCoord = m: pos:
        elemAt (elemAt m pos.y) pos.x;

      visit = position: visited:
    (lib.take position.y visited) ++ [(visitRow (elemAt visited position.y) position.x)] ++ (lib.drop (position.y + 1) visited);

  visitRow = row: x:
    (lib.take x row) ++ ["."] ++ (lib.drop (x + 1) row);


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

      wrap = m:
    let 
      blank = repeat "." (m |> head |> length |> (e: e + 2));
    in [blank] ++ (map (e: ["."] ++ e ++ ["."]) m) ++ [blank];


  nachbarn = pos:  
  map (f:
          {
            x = pos.x + f.x;
            y = pos.y + f.y;
          }
          ) directionDeltas
;

    tests = {
        part1 = [{
            input = testinput;
            expected = 12;
        }];
        part2 = [];
    };
in
{inherit part1 part2 tests;}
#parseInput realinput |> christmasTree 0
#modPositive (20) 7