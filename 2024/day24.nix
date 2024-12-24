with builtins; with (import ../lib.nix); let
  realinput = readFile ./day24.input;

  testinput = ''
    x00: 1
    x01: 1
    x02: 1
    y00: 0
    y01: 1
    y02: 0

    x00 AND y00 -> z00
    x01 XOR y01 -> z01
    x02 OR y02 -> z02
  '';

  parseInput = input: 
    let
      i = lib.splitString "\n\n" input |> filter (e: e != "");
      wires = head i
        |> lib.splitString "\n"
        |> filter (e: e != "")
        |> map (lib.splitString ": ")
        |> map (e: {name  = head e; value = elemAt e 1 == "1";})
        |> listToAttrs
        ;
      gates = elemAt i 1
        |> lib.splitString "\n"
        |> filter (e: e != "")
        |> map (gate:
          let
            blocks = lib.splitString " " gate;
            type = elemAt blocks 1;
            AND = a: b: a && b;
            OR = a: b: a || b;
            XOR = a: b: !((a -> b) && (b -> a));
          in
          rec {
            inputs = [(elemAt blocks 0) (elemAt blocks 2)];
            output = {
              wire = elemAt blocks 4;
              value = if type == "AND" then AND else
                      if type == "OR" then OR else
                      if type == "XOR" then XOR else
                      abort "unknown type";
            };
          }
        )
        ;
    in {
      inherit wires gates;
    };

    pow = base: exponent: 
      if exponent <= 0 then 1 else
      base * (pow base (exponent - 1));

    MonitoringDevice = {wires, gates, ...}: 
      let
        solvable = gate:
          all (e: hasAttr e wires) gate.inputs
          ;
        allOutputWires = (attrNames wires) ++ (map (e: e.output.wire) gates) |> filter (e: head (lib.stringToCharacters e) == "z") |> lib.unique;
        hasOutput = all (e: hasAttr e wires) allOutputWires;
        wireNumber = z: z |> lib.splitString "z" |> tail |> concat |> lib.toIntBase10;
        solvableGates = filter solvable gates;
        nextWires = foldl' (acc: curr: acc // { "${curr.output.wire}" = curr.output.value wires.${ head curr.inputs} wires.${elemAt curr.inputs 1}; }) wires solvableGates;
        nextGates = lib.subtractLists solvableGates gates;

      in rec {
        inherit wires gates;
      
        output = if ! hasOutput then next.output else
          map (wire: (pow 2 (wireNumber wire)) * (if wires.${wire} then 1 else 0)) allOutputWires
          |> sum
          ;
        next = MonitoringDevice {wires = nextWires; gates = nextGates;};

        self = { inherit wires gates self next; };
      };

in 
  (MonitoringDevice (parseInput realinput)).output
