with builtins; with (import ../lib.nix); let
  realinput = readFile ./day19.input;

  testinput = ''
    r, wr, b, g, bwu, rb, gb, br

    brwrr
    bggr
    gbbr
    rrbgbr
    ubwu
    bwurrg
    brgr
    bbrgwb
  '';

  notEmpty = l: filter (e: e != "") l;

  parseInput = input:
    let
      s = lib.splitString "\n\n" input |> notEmpty;
      a = head s;
      b = elemAt s 1;
    in {
      towels = lib.splitString ", " a |> notEmpty
        |> map (e: lib.splitString "" e |> notEmpty);
      patterns = lib.splitString "\n" b |> notEmpty
        |> map (e: lib.splitString "" e |> notEmpty);
    };

  possible = towels: pattern:
      let 
        beginnings = filter (towel:
          let 
            len = length towel;
            start = lib.take len pattern;
          in
          towel == start
        ) towels;
      in
    if pattern == [] then true else
    if length beginnings == 0 then false else
    any (curr: 
      let 
        len = length curr;
        remaining = lib.drop len pattern;
      in
        possible towels remaining
    ) beginnings;

    possibilities = cache: towels: pattern:
      let 
        beginnings = filter (towel:
          let 
            len = length towel;
            start = lib.take len pattern;
          in
          towel == start
        ) towels;

        next = (foldl' (acc: curr: 
            let 
              len = length curr;
              remaining = lib.drop len pattern;
              step = possibilities acc.cache towels remaining;
            in
            { sum = step.sum + acc.sum ; cache = step.cache // { "${concat remaining}" = step.sum ;};}
          ) {inherit cache; sum = 0;} beginnings);
      in
    if pattern == [] then { inherit cache; sum = 1; } else
    if hasAttr (concat pattern) cache then {inherit cache; sum =  cache.${concat pattern}; } else
    if length beginnings == 0 then  {inherit cache; sum = 0;} else
   { inherit (next) sum cache; };


  part1 = input: parseInput input
    |> (e: filter (possible e.towels) e.patterns)
    |> length
    ;

  part2 = input: parseInput input
    |> (e: map (possibilities {} e.towels) e.patterns)
    |> map (e: e.sum)
    |> sum
    ;


    

in
  part1 realinput
