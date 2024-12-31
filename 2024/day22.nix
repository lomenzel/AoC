with builtins; with (import ../lib.nix); let
  realinput = readFile ./day22.input;

  parseInput = input: input
    |> lib.splitString "\n"
    |> filter (e: e != "")
    |> map lib.toInt;


  next = secretNumber:
    let
      s64 = (secretNumber * 64);
      s64' = bitXor secretNumber s64;
      s64'' = modPositive s64' 16777216;

      s32 = s64'' / 32;
      s32' = bitXor s64'' s32;
      s32'' = modPositive s32' 16777216;

      s2048 = s32'' * 2048;
       s2048' = bitXor s32'' s2048;
      s2048'' = modPositive s2048' 16777216;
    in 
      s2048'';

  nextN = n: secretNumber:
    foldl' (acc: curr: next (trace (toString (price acc)) acc)) secretNumber (lib.range 1 n);

  price = secretNumber: modPositive secretNumber 10;



  part1 = input: input
    |> parseInput
    |> map (nextN 2000)
    |> sum;

in

 {inherit part1;}