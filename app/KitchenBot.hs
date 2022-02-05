module KitchenBot  where 
import Environment
import Element
import Utils
import Data.List
import BFS


moveAll:: Environment -> Environment
moveAll environment = 
    foldl KitchenBot.move environment (kitchenBots environment)

sortTuplesDistances (a1, b1) (a2, b2) = compare b1 b2

nearestKid:: Environment -> Position -> Maybe Element
nearestKid env pos = nearestPositionInCollection env pos (children env)
    
nearestDirt:: Environment -> Position -> Maybe Element
nearestDirt env pos = nearestPositionInCollection env pos (dirts env)

nearestPositionInCollection::Environment -> Position  -> [Element] -> Maybe Element
nearestPositionInCollection env initialPos collection = let elementWithDistances = map (\element -> (element, manhattanDistance initialPos (pos element)) ) collection
    in sortOn snd elementWithDistances
    >>> head'
    >>> fmap fst
  

tryGoToPosition:: Environment -> Element -> Position -> Environment
tryGoToPosition environment kitchenBot position = let element = getElementAtPosition environment position in
    let isKidInJailInPosition = any (\a -> a == (pos kitchenBot)) (map pos (childrenCatched environment))
    in case element of
        Nothing -> environment
        Just element -> 
            case (element,isKidInJailInPosition) of
                (EmptyCell(_,_),True) -> environment {
                        empties = deleteFromList element (empties environment),
                        kitchenBots = (deleteFromList kitchenBot (kitchenBots environment)) ++ [ KitchenBot (pos element)]
                    }
                (EmptyCell(_,_),False) -> environment {
                        empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos kitchenBot)],
                        kitchenBots = (deleteFromList kitchenBot (kitchenBots environment)) ++ [ KitchenBot (pos element)]
                    }
                (Child(_,_),True) -> environment {
                        empties = deleteFromList element (empties environment),
                        children = deleteFromList element (children environment),
                        kitchenBots = (deleteFromList kitchenBot (kitchenBots environment)),
                        bussyBots = bussyBots environment ++ [BussyBots(pos element)]
                    }
                (Child(_,_),False) -> environment {
                        empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos kitchenBot) ],
                        children = deleteFromList element (children environment),
                        kitchenBots = (deleteFromList kitchenBot (kitchenBots environment)),
                        bussyBots = bussyBots environment ++ [BussyBots(pos element)]
                    }
                (Dirt(_,_),True) -> environment {
                        empties = deleteFromList element (empties environment),
                        dirts = deleteFromList element (dirts environment),
                        kitchenBots = (deleteFromList kitchenBot (kitchenBots environment) ) ++ [ KitchenBot( pos element ) ]
                    }
                (Dirt(_,_),False) -> environment {
                        empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos kitchenBot) ],
                        dirts = deleteFromList element (dirts environment),
                        kitchenBots = (deleteFromList kitchenBot (kitchenBots environment) ) ++ [ KitchenBot( pos element ) ]
                    }
                (_) -> environment


move:: Environment -> Element -> Environment
move env kitchenBot = let (kidToPick , dirtToGo) = (nearestKid env (pos kitchenBot), nearestDirt env (pos kitchenBot)) in 
    let (bestPathToKid,bestPathToDirt ) = (fmap (shortestPathToElement env (pos kitchenBot)) kidToPick, fmap (shortestPathToElement env (pos kitchenBot)) dirtToGo)
    in case (bestPathToKid , bestPathToDirt) of
        (Just [],Just []) -> env
        (Just [], Just value) -> tryGoToPosition env kitchenBot (head value)
        (Nothing , Nothing) -> env
        (Nothing , Just []) -> env
        (Nothing , Just value) -> tryGoToPosition env kitchenBot (head value)
        (Just [] , _) -> env
        (Just value , _) -> tryGoToPosition env kitchenBot (head value)


-------------------------------------------------Smart stuff------------------------------------------------------------

--Similar to isDirty, but returns an int
isDirtInt:: Maybe Element -> Int
isDirtInt element = case element of 
            Nothing -> 0
            Just element ->
                case (element) of
                    (Dirt (_,_)) -> 1 
                    _ -> 0

-- Gets the dirtiness(amount of dirty elements) of a given path
dirtyness:: Environment -> [Position] -> Int
-- dirtyness env path = sum (map (isDirtInt (.) getElementAtPosition) path)
dirtyness env path = sum (map (\a -> isDirtInt (getElementAtPosition env a)) path)

shortestPathToElement:: Environment -> Position -> Element -> [Position]
shortestPathToElement env position element= bfsSearch env position isWalkable (pos element) 

isWalkable:: Element-> Bool 
isWalkable element = case (element) of
    (EmptyCell(_,_)) -> True
    (Child(_,_)) -> True
    (Dirt(_,_)) -> True
    (Playpen(_,_)) -> True
    (_) -> False
    