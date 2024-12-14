with builtins; with (import ../lib.nix); let

    part1 = input: "not implemented";
    part2 = input: "not implemented";


/* TYPES

 Robot = {
    position = Position
    velocity = Position
 }


*/

    # String -> [Robot...]
    parseInput = input: input
        |> lib.splitString "\n"
        |> filter (e: e != "")
        |> map (lib.splitString " ")
        |> map (filter (e: e != ""))
        |> map (map (e: split "(-?[0-9]+)" e |> filter (f: (!isString f)) |> flat |> map (lib.toInt)))
        |> map (robot:
            {
                position = vecToCoord (head robot);
                velocity = vecToCoord (elemAt robot 1);
            }
        )
        ;




    testinput = ''
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



    tests = {
        part1 = [{
            input = testinput;
            expected = 12;
        }];
        part2 = [];
    };
in
{inherit part1 part2 tests;}
#parseInput testinput