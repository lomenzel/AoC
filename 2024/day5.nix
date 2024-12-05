with builtins; let 
  lib = (import <nixos> {}).lib;

  sum = list: lib.fold (acc: curr: acc + curr) 0 list;
  product = list: lib.fold (acc: curr: acc * curr) 1 list;
  concat = list: lib.fold (acc: curr: acc + curr) "" list;
 
  input = readFile ./day5.input
    |> lib.splitString "\n\n"
    |> (e:
      {
        rules = head e 
          |> lib.splitString "\n"
          |> map (lib.splitString "|")
          |> map (map lib.toInt)
          |> rulesPerNumber;
        updates = elemAt e 1
          |> lib.splitString "\n"
          |> map (lib.splitString ",")
          |> map (map lib.toInt);
      }
    )
    ;

  rulesPerNumber = rules: rules
    |> map (e: {name = (toString (elemAt e 1)); value = onlyInFront e rules;})
    |> listToAttrs
    ;

  onlyInFront = rule: rules: rules
    |> filter (e: elemAt e 1 == elemAt rule 1)
    |> map head
    ;

  printable = update: 
    if length update == 0 then true else (
    (if hasAttr  "${toString (head update)}" input.rules then 
    ! any (e: elem e input.rules."${toString (head update)}") (tail update) else 
    true) && printable (tail update))
   ;

  flat = list: lib.fold (curr: acc: acc ++ curr) [] list;

  
  addEverywhere = item: allready: allready
    |> length
    |> lib.range 0
    |> map (addToPosition item allready)
    |> filter printable
    ;

  addToPosition = item: list: index:
    (lib.take index list) ++ [item] ++ (lib.drop index list);

  ordered = list: list
    |> lib.foldl (acc: curr: map (addEverywhere curr) acc |> flat) [[]]
    |> head;

  "Part 1" = input.updates
    |> filter printable
    |> map (e: elemAt e (length e / 2))
    |> sum;

  "Part 2" = input.updates
    |> filter (e: !printable e)
    |> map ordered
    |> map (e: elemAt e (length e / 2))
    |> sum
    ;
in 
  {inherit "Part 1" "Part 2";}
