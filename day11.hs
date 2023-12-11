import Data.List
import System.IO

testInput = "...#......\n.......#..\n#.........\n..........\n......#...\n.#........\n.........#\n..........\n.......#..\n#...#....."
expandy:: [String] -> [String]
expandy = foldl (\acc e -> if elem '#' e then acc ++ [e] else acc ++ [e,e]) []

expandUniverse:: [String] -> [String]
expandUniverse  = transpose . expandy . transpose . expandy 


element::Integer -> [a] -> a
element n list
    | n == 0 = head list
    | otherwise = element ( n - 1 ) (tail list)

second:: [a]->a
second = element 1

addIndex:: [[Integer]] -> Char -> [[Integer]]
addIndex i e
    | e == '#' = [[1 + ((head . head) i)], (second i) ++ [(head . head) i] ]
    | otherwise =  [[1 + ((head . head) i)], second i ]

indices:: String -> [Integer]
indices = second . (foldl addIndex) [[0],[]]

toCoordinate:: Integer -> [Integer] -> [[Integer]]
toCoordinate x ys = foldl (\acc e -> acc ++ [[x, e]]) [] ys

toIndices:: [String] -> [[Integer]]
toIndices = map indices

addCoordinates:: [[[Integer]]] -> [Integer] -> [[[Integer]]]
addCoordinates i l = [[[1 + ((head. head . head) i)]], ( head . tail ) i ++ (toCoordinate ((head .head . head) i) l)  ]  

toCoordinates :: [String] -> [[Integer]]
toCoordinates = second. ((foldl addCoordinates) [[[0]],[]]) . (map indices)

duplicate:: a -> [a]
duplicate e = [ e, e ] 

toDistance:: [[Integer]] -> Integer
toDistance p = (abs (( (head . head) p ) - ((head. second)p))) + (abs  (( (second . head) p ) - ((second . second)p)))

solution1:: String -> Integer
solution1 input = div ( (sum . (map toDistance) . sequence . duplicate . toCoordinates . expandUniverse . lines ) input) 2

withoutExpansion:: String -> Integer
withoutExpansion input = div ( (sum . (map toDistance) . sequence . duplicate . toCoordinates  . lines ) input) 2

emptyCrossing:: String -> Integer
emptyCrossing input = (solution1 input) - (withoutExpansion input)

solution2n:: Integer -> String -> Integer
solution2n n input = (withoutExpansion input) + (n * (emptyCrossing input))

solution2 :: String -> Integer
solution2 = solution2n 999999

solution :: IO ()
solution = do
    input <- readFile "./input11.txt"
    let 
        result = [solution1 input, solution2 input]

    print result