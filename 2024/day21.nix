with builtins; with (import ../lib.nix); let
  realinput = readFile ./day21.input;


  testinput = ''
    029A
    980A
    179A
    456A
    379A
  '';

  pins = input: lib.splitString "\n" input |> filter (e: e != "");

  numpad = ''
    789
    456
    123
    -0A
  '' |> grid.fromString;

  dirpad = ''
    -^A
    <v>
  '' |> grid.fromString;

  Keyboard = g: 
    Keyboard' g (g.find "A") [];

  Keyboard' = pad: position: output:
  if ! pad.isInside position || pad.get position == "-" then null else
  rec {
    inherit pad position output;
    actions = [{
        name = "^";
        value = Keyboard' pad (addPos position {x = 0; y = (-1);}) output;
      } {
        name = "v";
        value = Keyboard' pad (addPos position {x = 0; y = 1;}) output;
      } {
        name = "<";
        value = Keyboard' pad (addPos position {x = (-1); y = 0;}) output;
      } {
        name = ">";
        value = Keyboard' pad (addPos position {x = 1; y = 0;}) output;
      } {
        name = "A";
        value = Keyboard' pad position (output ++ [(pad.get position)]);
      }
    ] |> filter (e: e.value != null) |> listToAttrs;
    distanceTo = button: manhattanDistance position (pad.find button);
    toString = posToStr position +  "-" + concat output;
  };

  posToStr =  pos: "x${toString pos.x}y${toString pos.y}";

  wrapKeyboard = keyboard:
    wrapKeyboard' keyboard (dirpad.find "A");

  wrapKeyboard' = keyboard: position:
  if ! dirpad.isInside position || dirpad.get position == "-" then null else
  rec {
    inherit keyboard position;
    inherit (keyboard) output;
    pad = dirpad;
     actions = [{
        name = "^";
        value = wrapKeyboard' keyboard (addPos position {x = 0; y = (-1);});
      } {
        name = "v";
        value = wrapKeyboard' keyboard (addPos position {x = 0; y = 1;});
      } {
        name = "<";
        value = wrapKeyboard' keyboard (addPos position {x = (-1); y = 0;}) ;
      } {
        name = ">";
        value = wrapKeyboard' keyboard (addPos position {x = 1; y = 0;});
      }
    ] ++ (if hasAttr (pad.get position) keyboard.actions then 
        [{name = "A"; value =  wrapKeyboard' keyboard.actions.${pad.get position} position;}] else []
      ) |> filter (e: e.value != null) |> listToAttrs;
    distanceTo = button:  keyboard.distanceTo button + manhattanDistance position (dirpad.find "A");
    toString = posToStr position + keyboard.toString;
  };

  exampleActions'' = "<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A"  |> lib.splitString "" |> filter (e: e != "");
  exampleActions' = "v<<A>>^A<A>AvA<^AA>A<vAAA>^A" |> lib.splitString "" |> filter (e: e != "");
  exampleActions = "<A^A>^^AvvvA" |> lib.splitString "" |> filter (e: e != "");

  wrapKeyboardN = keyboard: n:
    if n == 0 then keyboard else wrapKeyboardN (wrapKeyboard keyboard) (n - 1);

  applyMultiple = keyboard: actions:
    foldl' (acc: curr: acc.actions.${curr}) keyboard actions;

  searchNode = goal: keyboard:
    let
      topLevelSteps = if length goal > length keyboard.output  then
       keyboard.distanceTo (head (lib.drop (length keyboard.output) goal)) else 0;
    in
   rec {
    inherit keyboard;
    heuristik = 
      lib.max 0 (length goal - length keyboard.output + topLevelSteps);
    next = 
      (if 
        length goal <= length keyboard.output 
        || keyboard.output != lib.take (length keyboard.output) goal
        then [] else attrNames keyboard.actions)
      |> map (action: searchNode goal keyboard.actions.${action}) 
      |> map (s: {cost =  1; state = trace "next: ${s.toString}" s;});
    reached = keyboard.output == goal;
    toString = keyboard.toString;
  };

  complexity = chainedRobots: pin:
    (aStar (searchNode (lib.splitString "" pin |> filter (e: e != "")) (wrapKeyboardN (Keyboard numpad) chainedRobots))).pathCost
    * lib.toIntBase10 (concat (lib.splitString "" pin |> filter (e: e != "A"))) ;


  part1 = input: pins input |> map (complexity 2) |> sum;
  part2 = input: pins input |> map (complexity 25) |> sum;




in
 testinput  
 |> pins
 |> map (lib.splitString "")
 |> map (filter (e: e != ""))
 |> map (e:
    lib.range 0 (length e - 1)
      |> map (f:
        if f == 0 then
          ["A" (elemAt e f)]
        else [ (elemAt e (f - 1)) (elemAt e f) ]
      )
  )
  |> flat
