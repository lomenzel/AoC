with builtins; with (import ../lib.nix); let
  realinput = readFile ./day17.input; # part 2 = 202972175280682

  parseinput = input: input
    |> lib.splitString "\n\n"
    |> (i:
      rec {
        memory = (head i)
          |> split "([A-Z]+): ([0-9]+)"
          |> filter (e: ! isString e)
          |> map (register:
            {name = head register; value = elemAt register 1 |> lib.toInt;}
          )
          |> listToAttrs
          ;
        program = elemAt i 1
          |> split "([0-9])"
          |> filter (e: ! isString e)
          |> flat
          |> map lib.toInt
          ;
      }
    )
  ;

  VM = mem: prog: pc: o: rec {
    memory = mem;
    program = prog;
    instructionPointer = pc;
    output = o;

    equals = vm: memory == vm.memory && program == vm.program;

    compute = let
        instruction = elemAt program instructionPointer;
        n = elemAt program (instructionPointer + 1);
        pow2 = n: if n == 0 then 1 else if n == 1 then 2 else 2 * (pow2 (n - 1));
        combOp = if n <= 3 then n else if n <= 6 then 
          elemAt (lib.attrsToList memory) (n - 4) |> (e: e.value) else abort "illegalCmboOperand ${toString n}";
        litOp = n;
        adv = VM (memory // { A = div memory.A (pow2 combOp); }) program (instructionPointer  + 2) output;
        bxl = VM (memory // { B = bitXor memory.B litOp; }) program (instructionPointer  + 2) output;
        bst = VM (memory // { B = modPositive combOp 8; }) program (instructionPointer  + 2) output;
        jnz = if memory.A == 0 then nop else
              VM memory program litOp output;
        bxc = VM (memory // { B = bitXor memory.B memory.C; }) program (instructionPointer + 2) output;
        out = VM memory program (instructionPointer + 2) (output ++ [(modPositive combOp 8)]);
        bdv = VM (memory // { B = div memory.A (pow2 combOp); }) program (instructionPointer  + 2) output;
        cdv = VM (memory // { C = div memory.A (pow2 combOp); }) program (instructionPointer  + 2) output;
        nop = VM memory program (instructionPointer + 2) output;
      in
        if instructionPointer >= length program then
          VM memory program instructionPointer output
        else
        if instructionPointer < 0 then abort "illegal instructionPointer ${toString instructionPointer}" else
        if instruction == 0 then adv.compute else
        if instruction == 1 then bxl.compute else
        if instruction == 2 then bst.compute else
        if instruction == 3 then jnz.compute else
        if instruction == 4 then bxc.compute else
        if instruction == 5 then out.compute else
        if instruction == 6 then bdv.compute else
        if instruction == 7 then cdv.compute else
        abort "illigal instruction ${toString instruction}";
  };

  testinput = ''
    Register A: 729
    Register B: 0
    Register C: 0

    Program: 0,1,5,4,3,0
  '';

  testinput2 = ''
    Register A: 2024
    Register B: 0
    Register C: 0

    Program: 0,3,5,4,3,0
  '';

  part1 = input: let
      i = parseinput input;
    in (VM i.memory i.program 0 []).compute.output |> map toString |> join ",";


  copyA = vm: vm.program == trace "${toString vm.compute.output}" vm.compute.output;

  repair = memory: program: a: VM (memory // { A = a;}) program 0 [];

  isAcorrect = i: a: repair i.memory i.program a |> copyA;

  findA = i: fa: la:  foldl' (acc: curr: if acc != null then acc else if isAcorrect i curr then curr else null) null (lib.range fa la);


  fstep = 10000;
  findaRec  = i: n: let s = findA i (trace "tested: ${toString n}" n) (n + fstep - 1); in
  if s != null then  s else findaRec i (n + fstep);


  upperBound  = i: n:
    let 
      s = (repair i.memory i.program n).compute.output;
    in
    if n > 202972175280711 then n else
    #if n > 202413590112921 && n < 202953971895281 then upperBound i (202953971895281) else
    if trace "s =${toString s}; n = ${toString n}\n gesucht  ${toString reali.program}" (length s) <= length i.program then upperBound i (n + 1) else
    n 
  ;
  
  lowerBound  = i: n:
    if length (repair i.memory i.program n).compute.output < (length i.program) - 1 then lowerBound i (n * 2) else
    n
  ;

  part2 = input: let
      i = parseinput input; 
    in
    #[
        (upperBound i 202972175280631)
        #(lowerBound i 1)
   # ]
      ;

  testi = parseinput testinput2;
  reali = parseinput realinput;

  

in
part2 realinput
#map (n: (repair reali.memory reali.program n).compute.output) (lib.range 0 80000) |> map length |> groupBy toString |> lib.attrsToList |> map (e: e.value) |> map length