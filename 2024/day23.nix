with builtins; with (import ../lib.nix); let
  realinput = readFile ./day23.input;

  testinput = ''
    kh-tc
    qp-kh
    de-cg
    ka-co
    yn-aq
    qp-ub
    cg-tb
    vc-aq
    tb-ka
    wh-tc
    yn-cg
    kh-ub
    ta-co
    de-co
    tc-td
    tb-wq
    wh-td
    ta-ka
    td-qp
    aq-cg
    wq-ub
    ub-vc
    de-ta
    wq-aq
    wq-vc
    wh-yn
    ka-de
    kh-ta
    co-tc
    wh-qp
    tb-vc
    td-yn
  '';

  parseInput = input: input
    |> lib.splitString "\n"
    |> filter (e: e!= "")
    |> map (lib.splitString "-")
    |> (e: 
      {
        connections = e ++ (map lib.reverseList e) 
          |> lib.groupBy (head)
          |> mapAttrs (name: value: map (e: elemAt e 1) value)
          ;
        computers = flat e |> lib.lists.unique;
      }
    );

  thirdPCs = connections: l: 
    lib.intersectLists connections.${head l} connections.${elemAt l 1} 
      |> map (e: [(head l) (elemAt l 1) e]);

  connectedToAll = connections: l:
    if l == [] then abort "i expect something to connect to" else
    foldl' (acc: curr: lib.intersectLists acc connections.${curr}) connections.${head l} (tail l)
      |> lib.subtractLists l
  ;

  withNext = connections: l:
    connectedToAll connections l
      |> map (e: l ++ [e] |> lib.lists.naturalSort)
      |> lib.unique
      #|> (e: trace "withNext ${toString (length e)}" e)
      #|> sort (a: b: a < b)
      ;

  part2 = input:
    let i = parseInput input;
    in with i;
     map (e: [e]) computers
     |> findLargestNet connections
     |> head
     |> join ","
     ;

  unique = l: 
    foldl' (acc: curr: acc // { "${join "," curr}" = true; }) {} (trace "unique ${toString (length l)}" l)
    |> attrNames
    |>  map (e: lib.splitString "," e |> filter (f: f!= ""))
    ;

  findLargestNet = connections: l:
    let 
      nextNet = map (withNext connections) (trace "length ${(toString (length l))} head ${toString (head l)}" l) |> flat;
    in
      if nextNet == [] then l else
        nextNet
        |> unique
        |> findLargestNet connections
        |> unique
        ;
  
  part1 = input: 
    let 
      i = parseInput input;
    in
    with i;
      (attrNames connections)
        |> filter (e: head (lib.stringToCharacters e) == "t")
        |> map (e: map (f: [e f]) connections.${e})
        |> flat
        |> map (thirdPCs connections)
        |> flat
        |> map lib.lists.naturalSort
        |> lib.unique
        |> length
     ;


  



in
  part2 realinput