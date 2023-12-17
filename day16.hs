import Debug.Trace
import System.IO
import Data.Bifunctor

testInput = ".|...\\....\n|.-.\\.....\n.....|-...\n........|.\n..........\n.........\\\n..../.\\\\..\n.-.-/..|..\n.|....-|.\\\n..//.|...."

up = 0
right = 1
left = 3
down = 2

applyDirectionMask :: Int -> [Bool] -> [Bool]
applyDirectionMask n m
    | null m = []
    | n == 0 = True : tail m
    | otherwise = head m : applyDirectionMask (n -1) (tail m)

directionMask:: Int -> [Bool]
directionMask n = applyDirectionMask n [False, False, False, False]

field :: String -> [[(Char,[Bool])]]
field = map fieldLine . lines

fieldLine:: String -> [(Char, [Bool])]
fieldLine = map (\e -> (e, [False, False, False, False]))

next':: ((Int, Int), Int) -> [[(Char,[Bool])]] -> [((Int, Int), Int)]
next' k f
    -- | (enlightementAt (fst k) f) !! (snd k) = []
    | charAt (fst k) f == '.' = [(uncurry nextInDirection k, snd k)]
    | charAt (fst k) f == '/' = [(nextInDirection (fst k) (nextDirection '/' $ snd k), nextDirection '/' $ snd k)]
    | charAt (fst k) f == '\\' = [(nextInDirection (fst k) (nextDirection '\\' $ snd k), nextDirection '\\' $ snd k)]
    | charAt (fst k) f == '-' && mod (snd k) 2 == 1 = [(uncurry nextInDirection k, snd k)]
    | charAt (fst k) f == '|' && even (snd k) = [(uncurry nextInDirection k, snd k)]
    | charAt (fst k) f == '-' = [(nextInDirection (fst k) left, left), (nextInDirection (fst k) right, right)]
    | charAt (fst k) f == '|' = [(nextInDirection (fst k) up, up), (nextInDirection (fst k) down, down)]
    | otherwise = error "something went wrong"

next :: ((Int, Int), Int) -> [[(Char,[Bool])]] -> [((Int, Int), Int)]
next k f = filter (isInBounds (length f) (length $ head f) . fst) $ next' k f

-- next k f = trace ("next " ++ show f ++ "\n" ++ show (next' k f) ++ " " ++ show k ++ " " ++ show (next2 k f)) $ next2 k f

merge :: [[(Char,[Bool])]] -> [[(Char,[Bool])]] -> [[(Char,[Bool])]]
merge a b
    | null a || null b = []
    | otherwise = mergeLine (head a) (head b) : merge (tail a) (tail b)

mergeLine :: [(Char,[Bool])] -> [(Char,[Bool])] -> [(Char,[Bool])]
mergeLine a b
    | null a || null b = []
    | otherwise = (fst (head a), oder (snd (head a)) (snd (head b))) : mergeLine (tail a) (tail b)

oder :: [Bool] -> [Bool] -> [Bool]
oder a b
    | null a || null b = []
    | otherwise = (head a || head b) : oder (tail a) (tail b)

isInBounds :: Int -> Int -> (Int, Int) -> Bool
isInBounds y x k = fst k < x && snd k < y && fst k >= 0 && snd k >= 0

nextDirection:: Char -> Int -> Int
nextDirection m d
    | m == '/'  && odd d = mod (d - 1) 4
    | m == '/'  && even d = mod (d + 1) 4
    | m == '\\' && odd d = mod (d + 1) 4
    | m == '\\' && even d = mod (d - 1) 4
    | otherwise = error "only works for / and \\"

nextInDirection :: (Int, Int) -> Int -> (Int, Int)
nextInDirection k r
    | r == left = (fst k - 1, snd k)
    | r == down = (fst k, snd k + 1)
    | r == up = (fst k, snd k - 1)
    | r == right = (fst k + 1, snd k)
    | otherwise = error "ungültige richtung"

charAt:: (Int, Int) -> [[(Char, [Bool])]] -> Char
charAt k f = fst (f !! snd k !! fst k)

enlightementAt::  (Int, Int) -> [[(Char, [Bool])]] -> [Bool]
enlightementAt k f = snd (f !! snd k !! fst k)

setEnlightement:: ((Int, Int), Int) -> [[(Char, [Bool])]] -> [[(Char, [Bool])]]
setEnlightement k f
    | snd (fst k) > 0 = head f : setEnlightement ((fst $ fst k, snd (fst k) - 1), snd k) (tail f)
    | otherwise = setEnlightementLine (Data.Bifunctor.first fst k) (head f) : tail f

setEnlightementLine :: (Int, Int) -> [(Char, [Bool])] -> [(Char, [Bool])]
setEnlightementLine k l
    | fst k > 0 = head l : setEnlightementLine (fst k - 1, snd k) (tail l)
    | otherwise = Data.Bifunctor.second (applyDirectionMask (snd k)) (head l) : tail l

enlighte:: ((Int, Int), Int) -> [[(Char, [Bool])]] -> [[(Char, [Bool])]]
enlighte k f
    | not (isEnlighted k f) = foldl (flip enlighte) (setEnlightement k f) (next k (setEnlightement k f))
    | otherwise = f

-- enlighte k f = trace("current" ++ show (currentEnlighted f) ++ " " ++ show (length f)) $ enlighte2 k f

isEnlighted:: ((Int, Int), Int) -> [[(Char, [Bool])]] -> Bool
isEnlighted k f = enlightementAt (fst k) f == applyDirectionMask (snd k) (enlightementAt (fst k) f)

flat :: Eq a => [[a]] -> [a]
flat a
    | null a = []
    | otherwise = head a ++ flat (tail a)

currentEnlighted = length . filter (or . snd) . flat

solution1 = currentEnlighted . enlighte ((0,0), right) . field

sol2 f s = (currentEnlighted . enlighte s) f

-- sol2 f s = trace ("progress " ++ show s) $ sol22 f s

toCoord2 len ndir = toCoord len (head ndir) (head (tail ndir))

toCoord len n dir
    | dir == up = ((n, len - 1), dir)
    | dir == down = ((n, 0), dir)
    | dir == left = ((len - 1, n), dir)
    | dir == right = ((0, n), dir)

solution2::[[(Char, [Bool])]] -> Int
solution2 f = (maximum . map (sol2 f . toCoord2 (length f))) (sequence [[0..length f-1], [0..3]])

main = do
    input <- readFile "input16.txt"
    print (solution2 $ field input)