module Simulation where

import Environment
import Element
import Child
import KitchenBot
import BFS
import BussyBots
import Utils

type Time = Int

totalTime = 30
timeForRandomChange = 10

environment =  initEnvironment 10 10
simEnvironment = simulate environment
cleanPercent = cleanPercentage simEnvironment


iteration::(Environment,Time) -> (Environment,Time)
iteration (env,time)
  |  mod (time) (timeForRandomChange) == 0 = ((env >>> changeEnvironment >>> KitchenBot.moveAll >>> BussyBots.moveAll >>> Child.moveAll), time + 1) 
  |  otherwise = ((env >>> KitchenBot.moveAll >>> BussyBots.moveAll >>> Child.moveAll), time + 1)

simulate::Environment -> Environment
simulate env = fst (simulate' (env, 0))

simulate'::(Environment,Time)->(Environment,Time)
simulate' (env, time) 
  | time == totalTime = (env,time)
  | otherwise = (env,time) >>> iteration >>> simulate'
