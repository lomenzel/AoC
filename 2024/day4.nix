with builtins; let
  lib = (import <nixos> { }).lib;
  input = readFile ./day4.input
    |> lib.splitString "\n";

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;

  rotate = m: m
    |> head
    |> stringLength
    |> (e: e - 1)
    |> lib.range 0
    |> map (colum m)
    |> map (lib.reverseList)
    |> map concat
    ;

  rotateBy = m: n: if n <= 0 then m else
    rotateBy (rotate m) (n - 1);

  allDirections = m: 3
    |> lib.range 0
    |> map (rotateBy m)
    |> map (countHorizontalAndDiagonal "XMAS")
    |> sum
    ;

  countHorizontalAndDiagonal = word: m:
    (count word m) + (count word (diagonal m));

  diagonal = m: m
    |> head
    |> stringLength
    |> (e: e + (length m) - 2)
    |> lib.range 0
    |> map (diagonalLine (prepareDiagonal m))
    ;

  diagonalLineHorizontalIndexes = m: index: m
    |> head
    |> stringLength
    |> (e: e - 1)
    |> lib.range 0
    |> map (e: e + index)
    ;

  diagonalLine = m: index: m
    |> head
    |> stringLength
    |> (e: e - 1)
    |> lib.range 0
    |> map (e:
      elemAt (lib.stringToCharacters (elemAt m (elemAt (diagonalLineHorizontalIndexes m index) e))) e
    )
    |> concat
    ;

  
  addCol = m: [(m
    |> head
    |> stringLength
    |> lib.range 1
    |> map (e: ".")
    |> concat)] ++ m ++ [(m
    |> head
    |> stringLength
    |> lib.range 1
    |> map (e: ".")
    |> concat)]
    ;

  addCols = m: n: if n <= 0 then m else 
    addCols (addCol m) (n - 1);

  prepareDiagonal = m: m
    |> head
    |> stringLength
    |> (e: e - 1)
    |> addCols m
    ;

  count = e: m: m
    |> map (split e)
    |> map (filter (e: !isString e))
    |> map length
    |> sum
    ;

  colum = m: i: m
    |> map (e: elemAt (lib.stringToCharacters e) i);

  isXMAS = m: coords:
     if elemAt (elemAt m coords.row) coords.col != "A" then false else 
     lib.naturalSort [(upLeft m coords) (downRight m coords)] == [ "M" "S" ] &&
     lib.naturalSort [(upRight m coords) (downLeft m coords)] == [ "M" "S" ]


    ;

  upLeft = m: coords:
    elemAt (elemAt m (coords.row - 1)) (coords.col - 1);


  downLeft = m: coords:
    elemAt (elemAt m (coords.row + 1)) (coords.col - 1);

  
  upRight = m: coords:
    elemAt (elemAt m (coords.row - 1)) (coords.col + 1);
  
  
  downRight = m: coords:
    elemAt (elemAt m (coords.row + 1)) (coords.col + 1);
  
  "Part 1" =  allDirections input
    ;
  "Part 2" = input
    |> (e: [(length e) (head e |> lib.stringLength)])
    |> map (e: e - 2)
    |> map (lib.range 1)
    |> (e: {row = head e; col = elemAt e 1;})
    |> lib.cartesianProductOfSets
    |> filter (isXMAS (map (lib.stringToCharacters) input))
    |> length
    ;
in
{ inherit "Part 1" "Part 2"; }
