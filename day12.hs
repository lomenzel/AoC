module Main where

import Data.List
import System.IO
import Data.Function.Memoize

testInput = "???.### 1,1,3\n.??..??...?##. 1,1,3\n?#?#?#?#?#?#?#? 1,3,1,6\n????.#...#... 4,1,1\n????.######..#####. 1,6,5\n?###???????? 3,2,1"

repl:: Char -> Char -> Char
repl rep e
    | e == rep = '\n'
    | otherwise = e

split:: Char -> String -> [String]
split rep line = lines (map (repl rep) line)

parse :: String -> Integer
parse a = read a :: Integer

iblocks:: String -> [Integer]
iblocks = (map parse) . (split ',') . head . tail . (split ' ')

blocks:: String -> [Integer]
blocks s =  filter (\e -> not (e == 0)) (reverse (foldl (\acc e -> if e == '#' then [(head acc) + 1] ++ (tail acc) else [0] ++ acc ) [0] s))

unknown:: String -> Integer
unknown = toInteger . length . (filter (== '?'))

ubroken:: String -> Integer
ubroken s = ((sum . iblocks) s) - ((toInteger . length . (filter (== '#'))) s)

needsToBeTested:: String -> [Integer]
needsToBeTested s = [unknown s, ubroken s]

nTimes:: a -> Integer -> [a]
nTimes a n
    | n == 0 = []
    | otherwise = [a] ++ (nTimes a (n-1))

timesN:: Integer -> a -> [a]
timesN i a = nTimes a i 

masks:: [Integer] -> [[Integer]]
masks a = betterMasks (head a) ((head . tail) a)


--betterMasks :: Integer -> Integer -> [[Integer]]
--betterMasks = memoize2 betterMasks'

betterMasks :: Integer -> Integer -> [[Integer]]
betterMasks n k 
    | n == 0 && k == 0 = [[]]
    | n == 0 = []
    | k == 0 = [nTimes 0 n]
    | otherwise = [0 : xs | xs <- (betterMasks (n-1) k)] ++ [1: xs | xs <- (betterMasks (n-1) (k-1))]

equals:: Eq a => [a] -> [a] -> Bool
equals a b 
    | a == [] && b == [] = True
    | a == [] || b == [] = False
    | not ((head a) == (head b)) = False
    | otherwise = equals (tail a) (tail b)

applyMask::String -> [Integer] -> String
applyMask s mask 
    | s == "" = ""
    | (head s) == '.' || (head s) == '#' = [head s] ++ applyMask (tail s) mask
    | (head s) == '?' && (head mask) == 1 = "#" ++ applyMask (tail s) (tail mask)
    | (head s) == '?' && (head mask) == 0 = "." ++ applyMask (tail s) (tail mask)
    | otherwise = "error"


masksToTest:: String -> [[Integer]]
masksToTest = masks . needsToBeTested

ibroken:: String -> String
ibroken = head . (split ' ')

isPossible::  [Integer] -> String -> Bool
isPossible m s = equals (iblocks s) (blocks (applyMask (ibroken s) m))

possibleMasks:: String -> [[Integer]]
possibleMasks s = filter (\e -> isPossible e s) (masksToTest s)


solution1 :: String -> Integer
solution1 input = sum (map (\l -> (countPossibilities (ibroken l) (iblocks l))) (lines input))

--Part 2

flat::[[a]] -> [a]
flat = foldl (\acc e -> acc ++ e) []

iblocksP2 :: String -> String
iblocksP2 = removeLast . flat . (timesN 5) . (add ',') . head . tail . (split ' ')

ibrokenP2 :: String -> String
ibrokenP2 = removeLast . flat . (timesN 5) . (add '?') . ibroken

p1lineToP2:: String -> String
p1lineToP2 s = (ibrokenP2 s) ++ " " ++ (iblocksP2 s)

add:: Char -> String -> String
add c s= s++[c]

removeLast :: String -> String
removeLast = reverse . tail . reverse

toP2Input :: String -> String
toP2Input = tail . (foldl (\acc e -> acc ++ "\n" ++ e) []) . (map p1lineToP2) . lines

second:: [a] -> a
second = head . tail

countPossibilities:: String -> [Integer] -> Integer
countPossibilities = memoize2 countPossibilities'

countPossibilities':: String -> [Integer] -> Integer
countPossibilities' l g
    | equals l "" && equals g [] = 1
    | equals l "" && equals g [0] = 1
    | equals l "" = 0
    | (head l) == '#' && equals g [] = 0
    | (head l) == '.' && equals g [] = countPossibilities (tail l) g
    | (head l) == '.' && (head g) == 0 = countPossibilities (tail l)  (tail g)
    | (head l) == '.' = countPossibilities (tail l) g
    | equals l "#" && (g == [] || (head g) == 0) = 0
    | equals l "#" && equals g [1] = 1
    | equals l "#" && (head g) > 1 = 0
    | equals l "#" && (length g) > 1 =0
    | (head l) == '?' = (countPossibilities ("#" ++ (tail l)) g) + (countPossibilities ("." ++ (tail l)) g)
    | (head l) == '#' && (head g) == 0 = 0
    | (head l) == '#' && (second l) == '#' && (head g) > 1 = countPossibilities (tail l) (((head g)-1): (tail g))
    | (head l) == '#' && (second l) == '#' && (head g) <= 1 = 0
    | (head l) == '#' && (second l) == '.' && (head g) == 1 = countPossibilities (tail l) (tail g)
    | (head l) == '#' && (second l) == '.' && (head g) /= 1 = 0
    | (head l) == '#' && (second l) == '?' = (countPossibilities ("#." ++ ((tail.tail)l)) g) + (countPossibilities ("##" ++ ((tail.tail)l)) g)
    | otherwise = 0



solution2 = solution1 . toP2Input

main :: IO ()
main = do
    input <- readFile "./input12.txt"
    let 
        result = solution2 input

    print result