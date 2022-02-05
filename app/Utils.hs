module Utils where
import System.IO.Unsafe  -- this is impure                                          
import System.Random

--remove item from list
deleteFromList :: Eq a => a -> [a] -> [a]
deleteFromList _ []                 = []
deleteFromList x (y:ys) | x == y    = deleteFromList x ys
                    | otherwise = y : deleteFromList x ys

mean:: [Float] -> Float
mean items = sum items / total
 where total = fromIntegral (length items) :: Float


-- Gets a random element in beetween fst and snd of Tuple. snd should be greater than
pickRandomInt:: (Int,Int) -> Int
pickRandomInt (m,n) = unsafePerformIO (getStdRandom (randomR (m, n)))

pickRandom :: [a] -> a 
pickRandom list
    | length list == 1 = list !! 0
    | otherwise = list !!
    unsafePerformIO (getStdRandom (randomR (0, (length list-1))))


manhattanDistance:: (Int,Int) -> (Int,Int) -> Int
manhattanDistance (m1,n1) (m2,n2) = abs (m1 - m2) + abs (n1 - n2)

-- F# pipe operator
(>>>) :: a -- ^ argument
  -> (a -> b) -- ^ function to apply
  -> b
a >>> b = b a


head' :: [a] -> Maybe a
head' []     = Nothing
head' (x:xs) = Just x
