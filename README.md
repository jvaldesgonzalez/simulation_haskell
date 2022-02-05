# Proyecto de Simulacion y Programacion Declarativa

## Tema: Agentes

- Javier Alejandro Valdes Gonzalez C-411

### Breve descripcion del problema:

El ambiente en el cual intervienen los agentes es discreto y tiene la forma de un rectangulo de N × M. El ambiente es de informacion completa, por tanto todos los agentes conocen toda la informacion sobre el agente. El ambiente puede variar aleatoriamente cada t unidades de tiempo. El valor de t es conocido.
Las acciones que realizan los agentes ocurren por turnos. En un turno, los agentes realizan sus acciones, una sola por cada agente, y modifican el medio sin que este varie a no ser que cambie por una accion de los agentes. En el siguiente, el ambiente puede variar.Si es el momento de cambio del ambiente, ocurre primero el cambio natural del ambiente y luego la variacion aleatoria. En una unidad de tiempo ocurren el turno del agente y el turno de cambio del ambiente.
Los elementos que pueden existir en el ambiente son obstaculos, suciedad, ninos, el corral y los agentes que son llamados Robots de Casa.

### Objetivo:

El objetivo del Robot de Casa es mantener la casa limpia a un 60%. Esta medida se calcula como el porcentaje de casillas vacias que no tienen suciedad.

### Ideas seguidas para la modelacion y solucion del problema:

El problema se modelo considerando los distintos elementos del ambiente, y el propio ambiente como una coleccion de estos, pues se considero que este enfoque mas comodo a modelar una matriz con elementos.

```haskell
data Environment
  = Environment {
      rowSize :: Int,
      columnSize:: Int,
      kitchenRobots :: [Element],
      children:: [Element],
      playpens :: [Element],
      obstacles :: [Element],
      dirts :: [Element],
      botsWithChildren :: [Element],
      childrenInPlaypen :: [Element],
      empties :: [Element]
  }
```

Todos los movimientos asociados a los elementos transforman el ambiente adicionando o eliminando a las listas.

Luego se define el pipeline del proceso como:

```haskell
Children.moveAll << BotWithKid.moveAll << Bot.moveAll << naturalMove << env
```

con `naturalMove` definido como el movimiento aleatorio del ambiente que ocurre cada `t` tiempo.

**Nota**: el operador (<<) se explicara en la seccion de implementacion.

Al ejecutar este pipeline se puede calcular finalmente cuanto queda limpio de la casa despues de un tiempo `T`.

### Modelos de Agentes

Se consideraron dos modelos reactivos:

1. El primer modelo de Robot busca siempre el nino mas cercano y se mueve en direccion a el de ser posible, si en el camino encuentra suciedad siempre decide limpiarla.
2. Se penso que se podia mejorar el resultado del primer modelos implementando una heuristica en el BFS a la hora de buscar el camino al nino mas cercano, usando asi el segundo agente un algoritmo A\* que primero analiza los nodos que contienen suciedad antes que los demas.

En ambos modelos, cuando los Robots de Cocina cargan un nino se mueven al corral vacio mas cercano y dejan el nino

### Ideas seguidas en la implementacion

El proyecto se construye usando `cabal`. Se usaron diferentes modulos descritos a continuacion:

1. Environment: Se describe el type Environment mostrado anteriormente, tambien conviven en el modulo las funcionalidades de inicializacion aleatoria del ambiente, reordenamiento aleatorio del ambiente y algunas utilidades como saber si un elemento tiene algun adyacente en el ambiente y la funcionalidad de indexar, es decir obtener el elemento de la posicion (i,j). De la forma que esta modelado siempre existira un elemento en la posicion (i,j), el caso de "vacio" en el mundo real seria un EmptyCell que pertenece a `empties environment`.
2. Utils: Se implemento el operador pipe `(>>)` bastante conocido en otros lenguajes funcionales, se decidio implementarlo pues resulto mucho mas comodo observar las transformaciones en forma de pipeline que en forma de composicion. Ademas se define la distancia entre dos posiciones, algunas utilidades de List como eliminar un elemento `deleteX:: Eq a => a -> [a] -> [a]`
3. Random: En este modulo estan los utils para la eleccion de un numero random dado un intervalo como elegir un elemento random de una lista. Se decidio no enfocarse tanto en realizar una funcion pura y con transparencia referencial ya que random conlleva un side-effect implicito y se uso `System.IO.Unsafe` a pesar de ser impuro, ya que son funcionalidades secundarias
4. BFS: Implementacion del algoritmo BFS
5. Directions: manejo de direcciones, desplazar en una direccion, etc

Se crearon ademas modulos para cada una de las partes que interactuan en el ambiente, todos estos podrian considerarse como "Movibles", y se expone en ellos una funcion que transforma un ambiente ejecutando el movimiento de todos los elementos de ese tipo, para ser mas claros:

```haskell
move::Movible A -> Env -> Env

moveA:: Env -> Env
moveA = foldl move env (elementos de tipo a del environment)
```

**NOTE**: Totalmente magico iterar una misma funcion n veces 🚀
`foldr (.) id (replicate n f) initialArg -- magic`

### Conclusiones

Se confirma que ambos agentes se desempenan de una manera pobre al disminuir el tiempo en que el ambiente cambia aleatoriamente, esto viene dado porque los agentes no consideran incertidumbre y solo planean para el momento, ambos agentes no conocen acerca del cambio aleatorio del ambiente y al ser reactivos solo siguen ejecutando decisiones conforme el estado actual del ambiente.

El primer modelo luego de 1000 simulaciones en una cuadricula de 10x10, iterando hasta T = 30 y cambiando el entorno de manera aleatoria cada 10 turnos tiene una media de porcentaje de limpieza de `63.33` con una desviacion estandard de `31.6`, esto con un maximo de 10% robots y 25% de infantes.

El segundo modelo bajo las mismas condiciones obtuvo una media de limpieza de `67.43` con una desviacion estandard de `34.29`

Esto nos lleva a concluir que ambos modelos se desempenan de manera similar, ya que hay muchos casos donde la heuristica pierde caminos muy poderosos
