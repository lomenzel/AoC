import Data.List
import System.IO


isFiveOfAKind a = ((filter (\x -> x /= (head a)) (tail a)) == [])
isFourOfAKind a = length (nub a) == 2 && any (\x -> (count x a) == 4) (nub a)
isFullHouse a = length (nub a) == 2 && any (\x -> (count x a) == 3) (nub a) && any (\x -> (count x a) == 2) (nub a)
isThreeOfAKind a = length (nub a) == 3 && any (\x -> (count x a) == 3) (nub a)
isTwoPairs a = length (nub a) == 3 && not (isThreeOfAKind a)
isOnePair a = length (nub a) == 4



isDistinct::[Char] -> Bool
isDistinct a = (length (nub a)) == 5

typWithoutJ :: String -> Integer
typWithoutJ a
    | isFiveOfAKind a = 7
    | isFourOfAKind a = 6
    | isFullHouse a = 5
    | isThreeOfAKind a = 4
    | isTwoPairs a = 3
    | isOnePair a = 2
    | isDistinct a = 1
    | otherwise = 0

typ a
    | count 'J' a == 0 = typWithoutJ a
    | otherwise = maximum [
        typWithoutJ (map (replJ '2') a),
        typWithoutJ (map (replJ '3') a),
        typWithoutJ (map (replJ '4') a),
        typWithoutJ (map (replJ '5') a),
        typWithoutJ (map (replJ '6') a),
        typWithoutJ (map (replJ '7') a),
        typWithoutJ (map (replJ '8') a),
        typWithoutJ (map (replJ '9') a),
        typWithoutJ (map (replJ 'T') a),
        typWithoutJ (map (replJ 'Q') a),
        typWithoutJ (map (replJ 'K') a),
        typWithoutJ (map (replJ 'A') a)
    ]

parse :: String -> Integer
parse a = read a :: Integer

count :: Eq a => a -> [a] -> Int
count x = length . filter (x==)



toNumber '2' = "02"
toNumber '3' = "03"
toNumber '4' = "04"
toNumber '5' = "05"
toNumber '6' = "06"
toNumber '7' = "07"
toNumber '8' = "08"
toNumber '9' = "09"
toNumber 'T' = "10"
toNumber 'J' = "01"
toNumber 'Q' = "12"
toNumber 'K' = "13"
toNumber 'A' = "14"
toNumber c = "0"

toNumbers:: [Char] -> Integer
toNumbers a = parse ("1" ++ (foldl (\x y -> (x ++ toNumber y)) "") a ) :: Integer


repl ' ' = '\n'
repl a = a
split a = lines (map repl a)

replJ a b 
    | b == 'J' = a
    | otherwise = b

toNumPair:: [[Char]] -> [Integer]

toNumPair a = [
    ( (toNumbers (head a)) + (100000000000* typ(head  a) )), 
    (parse (head (tail a)))
 ]


solution2:: [[Integer]] -> [Integer]
solution2 = (foldl (\acc pair -> ([(1+ (head acc)),(( (head (tail pair)) *(head acc))+(head(tail acc)))])) [1,0]) 

main :: IO ()
main = do
    input <- readFile "./input7.txt"
    let 
        isplit = map split (lines input)
        iparsed = sortBy (\a  b -> compare (head a) (head b)) (map toNumPair isplit)
        result = solution2 iparsed

    print result