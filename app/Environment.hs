module Environment where 

import Data.List
import Element
import Utils

data Environment
  = Environment {
      rowSize :: Int,
      colSize:: Int,
      kitchenBots :: [Element],
      children:: [Element], 
      playpens :: [Element], 
      obstacles :: [Element], 
      dirts :: [Element], 
      bussyBots :: [Element], 
      childrenCatched :: [Element], 
      empties :: [Element]
  } deriving (Show)

changeEnvironment:: Environment -> Environment
changeEnvironment env = let (oldKids, oldObstacles) = (children env, obstacles env) in env {
    children = [],
    obstacles = [],
    empties = empties env ++  map toEmptyCell oldKids ++ map toEmptyCell oldObstacles
  }
  >>> changeKidsInEnvironment (length oldKids) 
  >>> changeObstaclesInEnvironment (length oldKids)

changeKidsInEnvironment:: Int -> Environment -> Environment
changeKidsInEnvironment amount environment  = foldr (.) id (replicate amount createKid) environment -- more magic again!!

changeObstaclesInEnvironment:: Int -> Environment -> Environment
changeObstaclesInEnvironment amount environment  = foldr (.) id (replicate amount createObstacle) environment -- more magic again!!


initEnvironment :: Int -> Int -> Environment
initEnvironment rowSize colSize =
  Environment {
          rowSize = rowSize,
          colSize = colSize,
          kitchenBots = [],
          children = [],
          playpens = [],
          obstacles = [],
          dirts = [],
          bussyBots = [],
          childrenCatched = [],
          empties = [EmptyCell (n,m) | n <- [0 .. rowSize - 1], m <- [0 .. colSize - 1]]
        }
  >>> populateJails >>> populateKids >>> populateObstacles >>> populateBots


--------------------------------------------------------Jails Population--------------------------------------------------------

createJail:: Environment -> Environment
createJail environment
  | playpens environment == [] = do
    let emptyCell = pickRandom (empties environment) in environment {empties = deleteFromList emptyCell (empties environment), playpens = [Playpen (first emptyCell, second emptyCell)] }
  | otherwise =
    let possibleJail = pickRandom (filter (\a -> hasEmptyAdjacent a environment) (playpens environment))
      in let emptyAdjacent = pickRandom (getEmptyAdjacents possibleJail environment)
        in environment {empties = deleteFromList emptyAdjacent (empties environment), playpens= (playpens environment)++[Playpen (pos emptyAdjacent)]}


-- Picks a random number for jailsCount, then compose the function createJail `jailsCount` times with itself.
populateJails:: Environment -> Environment
populateJails environment =
  let jailsCount = pickRandomInt(1, maximum [1 ,(area environment * 25) `div` 100])
    in foldr (.) id (replicate jailsCount createJail) environment -- magic!!



-------------------------------------------------------- Kids Population --------------------------------------------------------
createKid:: Environment -> Environment
createKid environment =
    let emptyCell = pickRandom (empties environment) in environment {empties = deleteFromList emptyCell (empties environment), children = (children environment) ++ [Child (first emptyCell, second emptyCell)] }



-- Picks the number of playpens polulated in environment, then compose the function createKid `jailsCount` times with itself
populateKids:: Environment -> Environment
populateKids environment =
  let jailsCount =  length (playpens environment)
    in foldr (.) id (replicate jailsCount createKid) environment -- magic again!!


-------------------------------------------------------- Obstacles Population --------------------------------------------------------
createObstacle:: Environment -> Environment
createObstacle environment = do
    let emptyCell = pickRandom (empties environment) in environment {empties = deleteFromList emptyCell (empties environment), obstacles = obstacles environment ++ [Obstacle (first emptyCell, second emptyCell)] }



-- Picks the number of playpens populated in environment, then compose the function createObstacle `obstaclesCount` times with itself
populateObstacles:: Environment -> Environment
populateObstacles environment
  | (area environment * 10) `div` 100 > 0 = 
    let obstaclesCount = pickRandomInt(1, (area environment * 10) `div` 100) 
    in foldr (.) id (replicate obstaclesCount createObstacle) environment -- magic again!!
  | otherwise = environment

-------------------------------------------------------- Bots Population --------------------------------------------------------
createBot:: Environment -> Environment
createBot environment = do
    let emptyCell = pickRandom (empties environment) in environment {empties = deleteFromList emptyCell (empties environment), kitchenBots = kitchenBots environment ++ [KitchenBot (first emptyCell, second emptyCell)] }



-- Picks the number of playpens populated in environment, then compose the function createBot `botsCount` times with itself
populateBots:: Environment -> Environment
populateBots environment =
  let botsCount = pickRandomInt(1, maximum [1 ,(area environment * 10) `div` 100]) 
  in foldr (.) id (replicate botsCount createBot) environment -- magic again!!
  


-------------------------------------------------------- Environment utils --------------------------------------------------------

area :: Environment -> Int 
area environment = rowSize environment * colSize environment


-- Gets the cleaning percentage of the environment. Simulation should be ok if is grater than 60 %
cleanPercentage:: Environment-> Float 
cleanPercentage environment = 
    100.0 -  (dirtsSize / emptyEnvironmentSize)*100
    where dirtsSize = fromIntegral (length (dirts environment)) :: Float
          emptyEnvironmentSize = fromIntegral (length (empties environment) + length (dirts environment)) :: Float



getElementAtPosition :: Environment-> Position -> Maybe Element 
getElementAtPosition environment pos = 
  elements environment
  >>> filter (isElementAtPosition pos)
  >>> head'


elements :: Environment -> [Element]
elements environment = kitchenBots environment
  ++ children environment
  ++ playpens environment
  ++ childrenCatched environment
  ++ bussyBots environment
  ++ obstacles environment
  ++ dirts environment
  ++ empties environment
  

hasEmptyAdjacent:: Element -> Environment -> Bool
hasEmptyAdjacent element environment = any (isNear element) (empties environment)

getEmptyAdjacents:: Element-> Environment-> [Element]
getEmptyAdjacents element environment = filter (isNear element) (empties environment)

toEmptyCell::Element -> Element 
toEmptyCell e = EmptyCell (pos e)