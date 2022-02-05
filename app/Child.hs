module Child (moveAll) where
import Environment
import Element
import Utils
import Obstacle
import Dirt


tryGoToPosition:: Environment -> Element -> Position -> Environment
tryGoToPosition environment child position = let element = getElementAtPosition environment position in
    case element of
        Nothing -> environment
        Just element -> case (child,environment,element) of
            (_,_,EmptyCell(_,_)) -> let envStillClean =  environment {
                empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos child)],
                children = (deleteFromList child (children environment)) ++ [ Child (pos element)]
                } in Dirt.generateInSquare envStillClean element
            (_,_,_) -> environment


isValidMovement:: Element ->Element-> Bool
isValidMovement = isNear

getPosiblePositions:: Environment -> Element -> [Element]
getPosiblePositions environment child = filter ( isValidMovement child ) (empties environment ++ obstacles environment)

getRandomPosition:: Environment-> Element -> Element
getRandomPosition environment child
    | length (getPosiblePositions environment child) > 0 = pickRandom (getPosiblePositions environment child)
    | otherwise = child


deleteKid:: Environment -> Element -> Environment
deleteKid environment child =
        environment {children = deleteFromList child (children environment)}

move:: Environment -> Element -> Environment
move environment child =
        let element = getRandomPosition environment child
            in case (element) of
                (EmptyCell (_,_)) -> Child.tryGoToPosition (environment) (child) (pos element)
                (Obstacle (n,m)) -> let direction = directionToMove (child) (n,m)
                                    in let envWithObstaclesMoved = Obstacle.move (environment) (Obstacle(n,m)) (direction)
                                    in Child.tryGoToPosition (envWithObstaclesMoved ) (child) (pos element)
                _ -> environment


moveAll:: Environment -> Environment
moveAll environment =
    foldl Child.move environment (children environment)