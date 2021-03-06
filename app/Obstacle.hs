module Obstacle (move)  where 

import Environment
import Element
import Utils

tryGoToPosition:: Environment -> Element -> Position -> Environment
tryGoToPosition environment obstacle position = let element = getElementAtPosition environment position in
    case element of 
        Nothing -> environment
        Just element -> 
            case (obstacle,environment,element) of
                (_,_,EmptyCell(_,_)) -> environment {
                    empties = deleteFromList element (empties environment) ++ [ EmptyCell (pos obstacle)],
                    obstacles = (deleteFromList obstacle (obstacles environment)) ++ [ Obstacle (pos element)]
                    }
                (_,_,_) -> environment

shiftIfObstacle:: Environment -> Position -> Direction -> Environment
shiftIfObstacle environment position direction = 
    let element = getElementAtPosition environment position in
        case element of 
            Nothing -> environment
            Just element -> 
                case (environment ,element, direction) of
                    (environment ,Obstacle(n,m), direction) ->  move (environment) (Obstacle(n,m)) (direction)
                    (environment, _ , _) -> environment

move:: Environment -> Element -> Direction -> Environment
move environment obstacle direction =
    let position = add obstacle direction
            in tryGoToPosition (shiftIfObstacle (environment) (position) (direction)) obstacle position

