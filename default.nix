with builtins; let
  lib = (import <nixos> {}).lib;
  years = lib.range 2015 2100
    |> filter (year: pathExists "${toString ./.}/${toString year}")
    |> map (year:{
      days = lib.range 1 25
        |> filter (day: pathExists "${toString ./.}/${toString year}/day${toString day}.nix");
      inherit year;
    }
    )
    |> filter (year: year.days != [])
    ;

in
years
