with builtins; let
  lib = (import <nixos> { }).lib;

  sum = list: foldl'(acc: curr: acc + curr) 0 list;
  product = list: foldl' (acc: curr: acc * curr) 1 list;
  concat = list: foldl' (acc: curr: acc + curr) "" list;
  flat = list: foldl' (acc: curr: acc ++ curr) [ ] list;
  inc = n: n + 1;
  dec = n: n - 1;
  even = n: lib.mod n 2 == 0;
  repeat = e: n: if n == 0 then [ ] else [ e ] ++ repeat e (n - 1);
  odd = n: ! even n;
  input = readFile ./day11.input
    |> lib.splitString " "
    |> map lib.toInt
  ;

  rules = n:
  let 
    s = toString n;
    len = stringLength s;
  in
    if n == 0 then [1] else
    if lib.mod len 2 == 1 then [(2024 * n)] else
    [
      (substring 0 (len / 2) s |> lib.toIntBase10)
      (substring (len / 2) len s |> lib.toIntBase10)
    ];

  blinkStones = n: s: 
  if n <= 0 then [s] else
  rules s
    |> map (blinkStones (n - 1))
    |> flat
    ;
  

  blink = h: n: s: 
  if n == 0 then {inherit h; value = 1;} else
  if hasAttr (toString n) h && hasAttr (toString s) h.${toString n} then
     {value =  h.${toString n}.${toString s};
     inherit h;
     }
  else
  rules s 
   # |> map (blink h (n - 1))
    |> foldl' (acc: curr: let

      next = blink acc.h (n - 1) curr;

    in {
      h = updateH next.h (n - 1) curr next.value;
      sum = next.value + acc.sum; 
    }
    
    ) {inherit h; sum = 0;}
    |> (e: {h = updateH e.h n s e.sum; value = e.sum;})
    #|> (e: trace "n = ${toString n}; e = ${toString e.value}; s = ${toString s};" e )
    ;
    
  updateH = h: n: s: value:
    lib.recursiveUpdate h { "${toString n}" = {
      "${toString s}" = value;
    };}
  ;


  generate = lib.range 21 50
    |> map (e:
      trace "\"${toString e}\" = ${toString (blink e 0)};" e
    )
    ;

  part1 = input
    |> map (blink {} 25)
    |> map (e: e.value)
    |> sum;

  todo =[ 5851763 6571 0 526746 23 69822 9 989 ];

  part2 = input

    |> foldl' (acc: curr: 
    let
      newH = prepareH acc.h (75 - processBefore) curr;
      b = blink newH (75 - processBefore) curr;
      value = acc.value + b.value;
    in
      {
        h = b.h;
        value = trace "got to ${toString curr} value: ${toString value}" value;
      }
    
    ) {h = {}; value = 0;}
    
    #|> map (e: (blink (prepareH {} 75 e) 75 e).value)
    |> (e: e.value)
    #|>  (e: trace (toString e) e)
    #|> sum
    ;

  part2Sol =
  # 6571
  53879093456950 
  # 0
  + 22938365706844
  # 5851763
  # preprocess 20
  + 5751096199270 + 30717292892 + 1284889945962 + 25374174891 + 333410799088 + 27801577540 + 2676821998 + 24550326906
  + 6042662239860 + 3907006330  + 43530436351 + 156026738507  + 583833041244 + 3507473428  + 15870576001  
  + 443790367956  + 34075542844 + 184299583335  + 4550870777  + 9365421693   + 36799343472 + 10165343727 + 9027644652
  # 526746
  + 14558636300603 + 1389405776 + 1782110140 + 1859175067 + 1711400754 + 1548315068 + 12872813280285 + 1538409158
  + 1302344395 + 7796947764 + 5602284645 + 1450147199889
  # 23
  + 43939614390765
  # 69822
  + 12188458727176 + 1413218206 + 972162047 + 1253523807 + 6238334475594 + 1858912770 + 2614216069 + 2948907027787
  + 24564604214
  # 9
  + 31069966778992
  # 989
  + 24886645434666
;

  prepareH = h: n: s:
  (foldl' (acc: curr: 
  trace "Prepare ${toString s} step ${toString curr}"
  (blink acc curr s).h
 ) h (lib.range 0 n));

 processBefore = 23;

  # part2 = blink 75 input;
in #part2
part2Sol
#(blink (prepareH {} 75 526746) 75 526746).value
#blinkStones processBefore 69822
#|> length
#|> sort (a: b: a < b)
#    |> (e: trace "length ${toString (length e)}" e)
#    |> map (e: (blink (prepareH {} (75 - processBefore) e) (75 - processBefore) e).value)
 #   |> map (e: trace (toString e) e)
#    |> sum
#sort (a: b: a < b) input
#(blink {} 100 0).value