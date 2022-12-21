# asteroids
Proyecto 2 - Organizacion del computador (CI3815) - Astroids.

Integrantes:

Daniel Robayo, 18-11086. Santiago Finamore, 18-10125.

# Introducción.
Asteroid es un juego clásico de arcade y uno de los primeros juegos de computadora
comercialmente disponibles al publico. Asteroids se compone de un campo de juego en el
cual una pequeña nave debe esquivar y/o destruir los asteroides que flotan en el mapa. 
El objetivo de este proyecto es implementar en assembly una version simplificada de este 
juego.

# Estado del programa.
## Nave.
La nave se mueve correctamente y el *warping* funciona correctamente. Para el funcionamiento
de la nave se sobreescribio el manejador de interrupciones. En el manejador de 
interrupciones se detectan las interrupciones que vienen desde el teclado y de 
esta manera se controla la nave.

## Vidas.
Las vidas se generan cada minuto (300 refrescamientos). Al momento de creación de una
vida se le asigna una posicion y velocidad aleatoria. La vida sale desde el borde del
mapa y la colision de la vida con el jugador funciona correctamente.

## Asteroides.
Los asteroides se generan cada 5 segundos (25 refrescamientos). Al igual que con las 
vidas, se le asigna una posicion y velocidad aleatoria. Los asteroides salen desde el
borde del mapa y la colision de la vida con el asteroide funciona correctamente.

## Puntaje.
El puntaje aumenta con cada refrescamiento como es requerido en el proyecto. El 
valor de puntaje es usado para verificar cuando crear una vida o un asteroide.

## Game Over.
En el momento en el que el jugador se queda sin vidas, se muestra un mensaje de 
game over y el puntaje obtenido.

## En general.
El input del programa se espera en la consola MMIO de MARS. Antes de empezar la 
ejecucion del juego se debe de conectar manualmente esta consola a MIPS. La salida
del programa se muestra en la consola estandar (Run I/O) de MIPS. 

El refrescamiento se simula imprimiendo una sucesion de "\n" en la consola de MIPS.
El puntaje y las vidas del jugador se muestran en lineas aparte.

Solo se muestra un asteroide a la vez. Esto es que, de darse el momento en el que 
un asteroide este en el mapa y se deba generar otro asteroide, este segundo asteroide
no se generará.

En algunos casos la posicion anterior de la vida o de la nave no se borra del mapa
y se muestra su posicion previa y actual de ambos elementos.

**No se optó por puntos adicionales**

# Sobre la implementacion del programa
Antes de empezar el ciclo principal del programa se inicializa el manejador de interrupciones.
En el ciclo principal del programa funciona en tres etapas. La primera etapa se actualiza el 
campo de juego con las posiciones actuales de cada elemento del juego. La segunda etapa se encarga
de actualizar el puntaje e imprimirlo en la consola. La ultima etapa muestra en pantalla el campo
de juego y el 'refrescamiento'.

En el ciclo principal tambien se crean las vidas y los asteroides en caso de requerirse. En la segunda etapa
se ejecutan las funciones cleanPlayer, cleanLive y cleanAsteroid las cuales borran la posicion anterior
de cada elemento. Luego, se ejecutan las funciones updatePlayer, updateLive y updateAsteroid las cuales
actualizan la posiciones de cada elemento del juego.

Los datos de cada jugador se guardan en memoria, es decir que se usan diversos accesos a memoria para leer y 
escribir estos datos cuando es necesario.
