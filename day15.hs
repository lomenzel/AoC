testInput = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

repl:: Char -> Char -> Char
repl rep e
    | e == rep = '\n'
    | otherwise = e

split:: Char -> String -> [String]
split rep line = lines (map (repl rep) line)

toInts:: String -> [Int]
toInts = (foldl (\acc e -> acc ++ [fromEnum e])) []

hash:: String -> Int
hash = ((foldl (\acc e -> mod (17 * (acc + e)) 256)) 0) . toInts


parse:: String -> Int
parse s = read s :: Int

nTimes:: a -> Integer -> [a]
nTimes a n
    | n == 0 = []
    | otherwise = [a] ++ (nTimes a (n-1))

timesN:: Integer -> a -> [a]
timesN i a = nTimes a i 

emptyBoxes:: [[(String, Int)]]
emptyBoxes= nTimes [] 256

toAddLense:: String -> (Int, String, Int)
toAddLense = (\e -> (hash (head e), head e, parse ((head.tail) e))) . (split '=')

toRemoveLense:: String -> (Int, String)
toRemoveLense =  (\e -> (hash e, e)) . reverse . tail . reverse

third :: (Int, String, Int) -> Int
third (_, _, trd) = trd

second :: (Int, String, Int) -> String
second (_, s, _) = s

first :: (Int, String, Int) -> Int
first (f, _, _) = f




tryReplace:: (Int, String, Int) -> (String, Int) -> ((String, Int), Bool)
tryReplace source target
    | (second source) == (fst target) = ((fst target, third source), True)
    | otherwise = (target, False)

addToBox:: (Int, String, Int) -> [(String, Int)] -> [(String, Int)]
addToBox l b
    | b == [] = [(second l, third l)]
    | snd (tryReplace l (head b)) = [fst (tryReplace l (head b))] ++ tail b
    | otherwise  = [head b] ++ addToBox l (tail b)

addToBoxes:: (Int, String, Int)  -> [[(String, Int)]] -> [[(String, Int)]]
addToBoxes l b
    | b == [] = error "Keine box gefunden"
    | (first l) == 0 = [addToBox l (head b)] ++ (tail b)
    | otherwise = [head b] ++ (addToBoxes ((first l) - 1 , second l, third l) (tail b))

removeFromBox:: String -> [(String, Int)]  -> [(String, Int)]
removeFromBox l b
    | b == [] = b
    | (fst (head b)) == l = tail b
    | otherwise = [head b] ++ removeFromBox l (tail b)

removeFromBoxes:: (Int, String) -> [[(String, Int)]] -> [[(String, Int)]]
removeFromBoxes l b
    | b == [] = error "Keine box gefunden"
    | (fst l) == 0 = [removeFromBox (snd l) (head b)] ++ tail b
    | otherwise = [head b] ++ (removeFromBoxes (((fst l) -1,snd l)) (tail b))

applyToBoxes:: String -> [[(String, Int)]] -> [[(String, Int)]]
applyToBoxes l b
    | (length (filter (=='=') l)) == 1 = addToBoxes (toAddLense l) b
    | (length (filter (=='-') l)) == 1 = removeFromBoxes (toRemoveLense l) b
    | otherwise = error "Ungültiger input"


generateBoxes:: String -> [[(String, Int)]]
generateBoxes = (foldl (\acc e -> (applyToBoxes e acc)) emptyBoxes) . (split ',')

solution1:: String -> Int
solution1 = sum . (map hash) . (split ',')

focusingPower:: [[(String, Int)]] -> Int
focusingPower b
    | b == [] = 0
    | otherwise = (power (length b) ((reverse . head) b)) + (focusingPower . tail) b

power:: Int -> [(String, Int)] -> Int
power box ls
    | ls == [] = 0
    | otherwise = (box * (length ls) * ((snd . head) ls)) + (power box (tail ls))

solution2:: String -> Int
solution2 = focusingPower . reverse . generateBoxes