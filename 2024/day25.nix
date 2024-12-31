with builtins; with (import ../lib.nix); let
  realinput = readFile ./day25.input;

  testinput = ''
    #####
    .####
    .####
    .####
    .#.#.
    .#...
    .....

    #####
    ##.##
    .#.##
    ...##
    ...#.
    ...#.
    .....

    .....
    #....
    #....
    #...#
    #.#.#
    #.###
    #####

    .....
    .....
    #.#..
    ###..
    ###.#
    ###.#
    #####

    .....
    .....
    .....
    #....
    #.#..
    #.#.#
    #####
  '';

  parseInput = input:
  let 
    e = lib.splitString "\n\n" input |> filter (f: f != "");
    heights = block: 
      grid.fromString block
      |> (e: map (l: (count "#" l) - 1) e.transpose.state )
      ;
  in
   lib.cartesianProductOfSets {
      key = filter (thing: count "#" (head (grid.fromString thing).state) == 0) e
        |> map heights;
      lock = filter (thing: count "#" (head (grid.fromString thing).state) > 0) e
        |> map heights;
    };

  part1 = input:
    let
      add = l1: l2:
        lib.range 0 ((length l1) - 1)
        |> map (e: elemAt l1 e + elemAt l2 e)
        ;
    in
      parseInput input
        |> map (e: add e.key e.lock)
        |> filter (e: maximum e <= 5)
        |> length
        ;


in
  {inherit part1;}