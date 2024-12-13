with builtins; let
  readme = ''
  # Advent Of Code

  Hier gibt es meine Lösungen zu Advent of Code :)
  
  ${testreport}
  '';


  lib = (import <nixos> {}).lib;
  testreport = lib.range 2015 2100
    |> filter (year: pathExists "${toString ./.}/${toString year}")
    |> map (year:{
      days = lib.range 1 25
        |> filter (day: pathExists "${toString ./.}/${toString year}/day${toString day}.nix");
      inherit year;
    }
    )
    |> filter (year: year.days != [])
    |> map (y:
      y // {days = map (reportForDay y.year) y.days
          |> (import ./lib.nix).concat; }
    )
    |> map (e: 
    "## Jahr ${toString e.year}\n\n| Tag | Teil 1 | Teil 2| \n|-|-|-| \n"
      + e.days + "\n"
    )
    |> (import ./lib.nix).concat
    ;

  reportForDay = year: day: 
  let
    dayfile = (import "${toString ./.}/${toString year}/day${toString day}.nix");
  in
    if hasAttr "tests" dayfile &&
       hasAttr "part1" dayfile.tests &&
       hasAttr "part2" dayfile.tests &&
       hasAttr "part1" dayfile
    then
      "|${toString day}|${
        execTests dayfile.tests.part1 dayfile.part1
      }|${
        execTests dayfile.tests.part2 dayfile.part2
      }|\n"
    else
      "|${toString day}|🔜|🔜|\n"
  
  ;

  execTests = tests: f: tests
    |> map (test:
       (tryEval (f test.input)).success && f test.input == test.expected
    )
    |> filter (e: e)
    |> (e: if tests == [] then "❓" else if length e == length tests then "✅" else "🟥" )


  ;

  pkgs = import <nixpkgs> {};

in
pkgs.writeText "README.md" readme
