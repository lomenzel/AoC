import Data.List
import System.IO
import Debug.Trace
import Data.Function.Memoize

testInput = "O....#....\nO.OO#....#\n.....##...\nOO.#O....O\n.O.....O#.\nO.#..O.#.#\n..O..#O..O\n.......O..\n#....###..\n#OO..#...."

swp:: (Char, Char) -> (Char, Char)
swp a
    | (fst a) == '.' && (snd a) == 'O' = ('O', '.')
    | otherwise = a

swpLine:: (String, String) -> (String, String)
swpLine a
    |  ((fst a) == "" && (snd a) == "") = a
    | (fst a) /= "" && (snd a) /= "" = ( [fst (swp ((head . fst) a,  (head . snd) a))] ++ fst (swpLine (tail (fst a), tail (snd a))), [snd (swp ((head . fst) a,  (head . snd) a))] ++ snd (swpLine (tail (fst a), tail (snd a))))
    | otherwise = error "upsi"


hasO' :: String -> Bool
hasO' = memoize hasO

hasO:: String -> Bool
hasO l
    | (length (filter (=='O') l)) == 0 = False
    | otherwise =  True

lineIn':: [String] -> String -> [String]
lineIn' = memoize2 lineIn

lineIn:: [String] -> String -> [String]
lineIn b l
    | (length b) == 0 = [l]
    | (length b) >= 1 = [fst (swpLine (l, head b))] ++ lineIn (tail b) (snd (swpLine (l, head b)))


o:: String -> Int
o = length . (filter (=='O'))

onums:: [Int] -> Int
onums a
    | a == [] = 0
    | otherwise = ((head a) * (length a))+ onums (tail a)

moveUp:: [String] -> [String]
moveUp = (foldl (\acc e -> lineIn acc e) []) . reverse

nwse :: [String] -> [String]
nwse = memoize nwse'

nwse':: [String] -> [String]
nwse' = rotate. moveUp . rotate . moveUp . rotate . moveUp . rotate . moveUp

rotate:: [[a]] -> [[a]]
rotate = transpose . reverse

nwseN:: Integer -> [String] ->  [String]
nwseN n b
    | n == 0 = b
    | otherwise  = nwseN (n - 1) (nwse b)
    
solution1 = onums . (map o) . moveUp . lines
solution2 = onums . (map o) . (nwseN 1000000000) . lines

main :: IO ()
main = do
    input <- readFile "./input14.txt"
    let 
        result = solution2 input

    print result