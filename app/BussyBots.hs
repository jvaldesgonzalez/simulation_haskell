module BussyBots where 
import Environment
import Element
import Utils
import Data.List
import BFS


moveAll:: Environment -> Environment
moveAll environment = 
    foldl BussyBots.move environment (bussyBots environment)

sortTuplesDistances (a1, b1) (a2, b2) = compare b1 b2

nearestJail:: Environment -> Position -> Maybe Element
nearestJail env pos = nearestPositionInCollection env pos (playpens env)
    
nearestDirt:: Environment -> Position -> Maybe Element
nearestDirt env pos = nearestPositionInCollection env pos (dirts env)

nearestPositionInCollection::Environment -> Position  -> [Element] -> Maybe Element
nearestPositionInCollection env initialPos collection = let elementWithDistances = map (\element -> (element, manhattanDistance initialPos (pos element)) ) collection
    in sortOn snd elementWithDistances
    >>> head' 
    >>> fmap fst
  

tryGoToPosition:: Environment -> Element -> Position -> Environment
tryGoToPosition environment kitchenBot position = let element = getElementAtPosition environment position in
    case element of
        Nothing -> environment
        Just element ->  
            case (element) of
                (EmptyCell(_,_)) -> environment {
                        empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos kitchenBot)],
                        bussyBots = (deleteFromList kitchenBot (bussyBots environment)) ++ [ BussyBots (pos element)]
                    }
                (Dirt(_,_)) -> environment {
                        empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos kitchenBot) ],
                        dirts = deleteFromList element (dirts environment),
                        bussyBots = (deleteFromList kitchenBot (bussyBots environment)) ++ [ BussyBots (pos element)]
                    }
                (Playpen(_,_)) -> environment {
                        empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos kitchenBot) ],
                        playpens = deleteFromList element (playpens environment),
                        bussyBots = (deleteFromList kitchenBot (bussyBots environment)),
                        kitchenBots = kitchenBots environment ++ [ KitchenBot( pos element ) ],
                        childrenCatched = childrenCatched environment ++ [ChildrenCatched( pos element )]
                    }
                (_) -> environment


move:: Environment -> Element -> Environment
move env kitchenBot = let (jailToGo , dirtToGo) = (nearestJail env (pos kitchenBot), nearestDirt env (pos kitchenBot)) in 
    let (bestPathToJail , bestPathToDirt ) = (fmap (shortestPathToElement env (pos kitchenBot)) jailToGo, fmap (shortestPathToElement env (pos kitchenBot)) dirtToGo)
    in case (bestPathToJail , bestPathToDirt) of
        (Just [],Just []) -> env
        (Just [], Just value) -> tryGoToPosition env kitchenBot (head value)
        (Nothing , Nothing) -> env
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
--TODO: check if this works, porke ta mas chula
dirtyness env path = sum (map (\a -> isDirtInt (getElementAtPosition env a)) path)

shortestPathToElement:: Environment -> Position -> Element -> [Position]
shortestPathToElement env position element= bfsSearch env position BussyBots.isWalkable (pos element) 

isWalkable:: Element-> Bool 
isWalkable element = case (element) of
    (EmptyCell(_,_)) -> True
    (Dirt(_,_)) -> True
    (Playpen(_,_)) -> True
    (_) -> False
    