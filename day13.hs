import Data.List
import System.IO
import Debug.Trace

testInput =  "#.##..##.\n..#.##.#.\n##......#\n##......#\n..#.##.#.\n..##..##.\n#.#.##.#.\n\n#...##..#\n#....#..#\n..##..###\n#####.##.\n#####.##.\n..##..###\n#....#..#"

tailOrEmpty:: [a]-> [a]
tailOrEmpty a
    | length a < 2 = []
    | otherwise = tail a

blocks :: [String] -> [[String]]
blocks s
    | length s == 0 = []
    | otherwise = [(fst (break (=="") s))] ++ ((blocks . tailOrEmpty . snd . (break (==""))) s)

equals:: Eq a => [a] -> [a] -> Bool
equals a b 
    | a == [] && b == [] = True
    | a == [] || b == [] = False
    | not ((head a) == (head b)) = False
    | otherwise = equals (tail a) (tail b)

equalStart :: [String] -> [String] -> Bool
equalStart a b
    | a == [] || b == [] = True
    | equals (head a) (head b) = equalStart (tail a) (tail b)
    | otherwise = False

isMirror:: [String] -> [String] -> Bool
isMirror a b = equalStart (reverse a)  b

mirrorIndex:: [String] -> Int
mirrorIndex = mirrorIndex' 1 

mirrorIndex':: Int -> [String] -> Int
mirrorIndex' i s
    | i >= (length s) = 0
    | isMirror (fst (splitAt i s) ) (snd (splitAt i s) )= i
    | otherwise = mirrorIndex' (i+1) s

blockScore:: [String] -> Int
blockScore b
    | (mirrorIndex b) == 0 =  mirrorIndex(transpose b)
    | otherwise = (mirrorIndex b) * 100

blockScoreNot:: Int -> [String] -> Integer
blockScoreNot n b
    | (mirrorIndexNot (div n 100) b) == 0 =  mirrorIndexNot n (transpose b)
    | otherwise = (mirrorIndexNot (div n 100) b) * 100

mirrorIndexNot:: Int -> [String] -> Integer
mirrorIndexNot n s = mirrorIndexNot' n 1 s

mirrorIndexNot':: Int -> Int -> [String] -> Integer
mirrorIndexNot' n i s
    | i >= (length s) = 0
    | isMirror (fst (splitAt i s) ) (snd (splitAt i s)) && not (i == n) = toInteger i
    | otherwise = mirrorIndexNot' n (i+1) s

findBlockScoreNot:: Int -> Int -> Int -> [String] -> Integer
findBlockScoreNot n x y b
    | y == length b = trace ("Parameters: " ++ show n ++ ", " ++ show x ++ ", " ++ show y ++ ", " ++ show b) $
                      error "oops"
    | x == length (head b) = findBlockScoreNot n 0 (y+1) b
    | (blockScoreNot n (replace x y b)) /= 0 = blockScoreNot n (replace x y b)
    | x < length (head b) = findBlockScoreNot n (x+1) y b


replace:: Int -> Int -> [String] -> [String]
replace x y b = (take y b) ++  [(replaceX x (atN y b))] ++ (drop (y+1) b)

replaceX:: Int -> String -> String
replaceX x s
    | atN x s == '#' = (take x s) ++ "." ++ (drop (x + 1) s)
    | otherwise = (take x s) ++ "#" ++ (drop (x + 1) s)

atN:: Int -> [a] -> a
atN n = head . (drop n)

solution1 = sum . (map blockScore) . blocks . lines

solution2 = sum . (map (\e -> findBlockScoreNot (blockScore e) 0 0 e)) . blocks . lines