module Element where 

import Utils

type Position = (Int,Int)

data Element = 
              KitchenBot{pos::Position}
            | Child{pos::Position}
            | BussyBots {pos::Position}
            | Dirt {pos::Position}
            | EmptyCell {pos::Position}
            | Playpen {pos::Position}
            | ChildrenCatched {pos::Position}
            | Obstacle {pos::Position}
            deriving (Eq , Ord, Show)

first:: Element -> Int
first x =  fst (pos x) 

second:: Element -> Int
second x = snd (pos x)

isNear:: Element -> Element -> Bool
isNear e1 e2 = isPosNear (pos e1) (pos e2)

isPosNear:: Position -> Position -> Bool
isPosNear p1 p2 = manhattanDistance p1 p2 <= 1

isElementAtPosition:: Position -> Element -> Bool
isElementAtPosition position element =
  pos element == position


--------------------------------------------------------Directions--------------------------------------------------------

data Direction = N | S | E | W
    deriving (Show,Eq)

directionVector:: Direction -> (Int,Int)
directionVector N = (1,0)
directionVector S = (-1,0)
directionVector W = (0,-1)
directionVector E = (0,1)

fromVector :: (Int,Int) -> Direction
fromVector (n,_)
  | n > 0 = N
  | n < 0 = S
fromVector (_,m)
  | m < 0 = W
  | m > 0 = E

add:: Element -> Direction -> Position 
add element direction = 
    let elementPos = pos element
    in (fst elementPos + fst (directionVector direction), snd elementPos + snd (directionVector direction))

directionToMove:: Element -> Position -> Direction
directionToMove element position = 
  let vector = (fst position - fst (pos element), snd position - snd (pos element))
  in fromVector vector
