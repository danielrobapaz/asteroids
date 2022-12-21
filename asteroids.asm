.data

grid: .asciiz "#########################\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#########################\n"

#Informacion del asteroide 1
asteroid1InField: .space 1 #Indica si hay o no un asteroide en el campo
asteroid1PosX: .space 1 #Posicion en X del asteroide, varia entre 1 y 20
asteroid1PosY: .space 1 #Posicion en Y del asteroide, varia entre 3 y 8
asteroid1SpX: .space 1 #Velocidad del asteroide en X, varia entre -2 y 2
asteroid1SpY: .space 1 #velocidad del asteroide en Y, varia entre -1 y 1

#Espacio para la informacion de los demas asteroides. Se accede a esta información pode desplazamiento
#A partir de la locacion de la informacion del primer asteroide
asteroidInfo: .space 15

.text
j main

##Funcion que dada la dirección inicial del tramo que contiene los datos de un asteroide
#no presente en el juego crea los datos de un nuevo asteroide. La dirección recibida como input
#se encuentra en $t0
createAsteroid:
	#Se busca el primer asteroide disponible
	la $t0, asteroid1InField
	li $t1, 4
findAvailableLoop:
	lb $t2, ($t0)
	beqz $t2, foundAvailableCreate
	addi $t0, $t0, 5  #Si esta ocupado se va al siguiente asteroide
	subi $t1, $t1, 1
	bnez $t1, findAvailableLoop
	j noAsteroid  #Si todos los asteroides estan ocupados se retorna la funcion
	
foundAvailableCreate:
	li $t1, 1  #Se marca el asteroide como existente
	sb $t1, ($t0)
	addi $t0, $t0, 1  #Se avanza al byte que contiene la posicion en X
	
	li $v0, 42   #Se escoge aleatoriamente una posición en X entre 1 y 20 (Campo jugable)
	li $a1, 19
	syscall
	addi $a0, $a0, 1
	move $t1, $a0  #Se guardan las posiciones elegidas para asistir en la escogencia de velocidades
	sb $a0, ($t0)  #Se guarda en memoria
	
	addi $t0, $t0, 1  #Se avanza al byte que contiene la posicion en Y
	
	#Si la posicion en X es en alguno de los bordes se debe escoger una posicion aleatoria en Y
	beq $a0, 1 chooseYPos
	beq $a0, 20 chooseYPos
	
	#Si no esta en alguno de los bordes laterales, se escoge al azar si originarlo en el borde superior 
	#o el inferior
	li $v0, 42
	li $a1, 1
	syscall
	
	mul $a0, $a0, 5
	addi $a0, $a0, 3
	move $t2, $a0 #Se guardan las posiciones elegidas para asistir en la escogencia de velocidades
	sb $a0, ($t0)
	
	addi $t0, $t0, 1  #Se avanza al byte que contiene la velocidad en X
	
#Seleccion de velocidades en X y Y
continueCreateAsteroid:
	
	li $v0, 42   #Se escoge aleatoriamente una velocidad entre -2 y 2 en X
	li $a1, 4
	syscall
	subi $a0, $a0, 2
	sle $t4, $t1, 4  #Si el asteroide fue generado muy a la izquierda y tiene velocidad negativa en X
	sle $t5, $a0, 0  #se le da un empujon a la derecha para evitar que desaparezca muy rapido
	and $t4, $t5, $t4
	bnez $t4, giveRightPush #Si se cumplen ambas condiciones se aumenta la velocidad del asteroide a la derecha
	
	sge $t4, $t1, 17  #Igual que antes, si el asteroide es generado muy a la derecha y tiene velocidad positiva
	sge $t5, $a0, 0   #se leda un empujon a la izquierda
	and $t4, $t4, $t5
	bnez $t4, giveLeftPush
	
storeSpeedX:
	sb $a0, ($t0)  #Se almacena la velocidad  en X calculada
	addi $t0, $t0, 1  #Se avanza al byte que contiene la velocidad en Y
	
	li $v0, 42  ##Se escoge una nueva velocidad aleatoria entre -1 y 1 para Y
	li $a1, 2   ##(Hay muy poquitos caracteres en Y 2 de velocidad me parece mucho jeje)
	syscall
	subi $a0, $a0, 1
	sle $t4, $t2, 5  #Si el asteroide fue generado muy a hacia arriba y tiene velocidad negativa en Y
	sle $t5, $a0, 0  #se le da un empujon hacia abajo
	and $t4, $t4, $t5
	bnez $t4, giveDownPush
	
	sge $t4, $t2, 6  #Empujon hacia abajo si el asteroide fue renderizado muy abajo y con velocidad 
	sge $t5, $a0, 0  #positiva.
	and $t4, $t4, $t5
	bnez $t4, giveUpPush
	
storeSpeedY:
	sb $a0, ($t0)
	jr $ra #Termina la función, se regresa al programa principal
	
giveRightPush:
	addi $a0, $a0, 2
	j storeSpeedX

giveLeftPush:
	addi $a0, $a0, -2
	j storeSpeedX
	
giveDownPush:
	addi $a0, $a0, 2
	j storeSpeedY
	
giveUpPush:
	addi $a0, $a0, -2
	j storeSpeedY
	
chooseYPos:
	
	li $v0, 42  #Se escoge un numero aleatorio entre 3 y 8 (Campo jugable)
	li $a1, 5
	syscall
	
	addi $a0, $a0, 3
	move $t2, $a0  #Se guardan las posiciones elegidas para asistir en la escogencia de velocidades
	sb $a0, ($t0)
	j continueCreateAsteroid


##
#Procedimiento que recibe la direccion inicial en memoria de un asteroide (Almacenada en $t0)
#Y actualiza su posicion basada en su posicion actual y sus velocidades. Si el asteroide queda
#fuera del area jugable luego de ser actualizado tambien se encarga de marcarlo como no presente.
updateAsteroid:
	lb $t1, ($t0)  
	beqz $t1, noAsteroid  #Si el asteroide ingresado no esta en el campo se retorna automaticamente

	addi $t0, $t0, 1  #Se accede a la posicion en X y se guarda en $t1
	lb $t1, ($t0)
	addi $t0, $t0, 1  #Se accede a la posicion en Y y se guarda en $t2
	lb $t2, ($t0)
	addi $t0, $t0, 1  #Se accede a la velocidad en X y se almacena en $t3
	lb $t3, ($t0)
	addi $t0, $t0, 1  #Se accede a la velocidad en Y y se almacena en $t4
	lb $t4, ($t0)
	
	add $t1, $t1, $t3  #Se suman las velocidades a las posiciones actuales del asteroide
	add $t2, $t2, $t4
	
	#Si luego de ser movido el asteroide hace contacto con alguna frontera se remueve del
	#mapa y se va directo a imprimir el frame
	
	sle $t3, $t1, 1  #Si esta tocando el lado izquierdo
	sle $t4, $t2, 3  #Si esta tocando el borde superior
	or $t3, $t3, $t4
	sge $t4, $t1, 20  #Si esta tocando el lado derecho
	or $t3, $t3, $t4
	sge $t4, $t2, 8  #Si esta tocando el borde inferior
	or $t3, $t3, $t4
	bnez $t3, removeAsteroid
	
	#Si el asteroide no debe ser removido se almacenan las nuevas posiciones
	subi $t0, $t0, 3
	sb $t1, ($t0)
	addi $t0, $t0, 1
	sb $t2, ($t0)
	jr $ra #Se sale de la función
	
removeAsteroid:
	subi $t0, $t0, 4  #Se devuelve $t0 a la posicion del byte de existencia
	li $t5, 0
	sb $t5, ($t0)  #Se cambia el byte de existencia a 0
	jr $ra  #Se sale de la funcion
	


##
#Procedimiento que limpia el los caracteres ocupados por un asteroide en pantalla.
#Necesario para que los asteroides no dejen rastro al moverse. Recibe la direccion
#del asteroide a limpiar en $t0
cleanAsteroid:
	#Si el asteroide ingresado no esta en pantalla se retorna automaticamente
	lb $t1, ($t0)
	beqz $t1 noAsteroid

	addi $t0, $t0, 1
	lb $s2, ($t0)  #Ubicacion en X
	addi $t0, $t0, 1
	lb $s3, ($t0)  #Ubicacion en Y

	li $s0, 32  #ASCII para " "
	li $s1, 3  #Contador del ciclo
	
	#Se calcula la direccion en memoria del pixel del mapa correspondiente
	#a la esquina inferior izquierda del asteroide (address = grid + (25*y + x))
	la $s4, grid
	mul $s3, $s3, 26
	add $s2, $s3, $s2
	add $s2, $s2, $s4  #$s2 contiene la direccion del pixel correspondiente a la esquina inferior izquierda del asteroide
	
	addi $s2, $s2, 3
	
cleanAsteroidLoop:
	sb $s0, ($s2)
	subi $s2, $s2, 1
	sb $s0, ($s2)
	subi $s2, $s2, 1
	sb $s0, ($s2)
	subi $s2, $s2, 1
	sb $s0, ($s2)
	subi $s2, $s2, 23
	subi $s1, $s1, 1
	bnez $s1, printAsteroidLoop
	jr $ra
	
##
#Procedimiento que recibe las coordenadas de un asteroide almacenadas en $t1 y $t2 y activa los pixeles
#correspondientes al asteroide en el campo de juego.
printAsteroid:
	lb $t1, ($t0)
	beqz $t1, noAsteroid  #Si el asteroide ingresado no esta en el campo se retorna inmediatamente
	
	addi $t0, $t0, 1
	lb $s2, ($t0)  #Posicion en X
	addi $t0, $t0, 1
	lb $s3, ($t0)  #Posicion en Y
	
	li $s0, 76  #ASCII para "L"
	li $s1, 3  #Contador del ciclo
	
	#Se calcula la direccion en memoria del pixel del mapa correspondiente
	#a la esquina inferior izquierda del asteroide (address = grid + (25*y + x))
	la $s4, grid
	mul $s3, $s3, 26
	add $s2, $s3, $s2
	add $s2, $s2, $s4  #$s2 contiene la direccion del pixel correspondiente a la esquina inferior izquierda del asteroide
	
	addi $s2, $s2, 3
	
printAsteroidLoop:
	sb $s0, ($s2)
	subi $s2, $s2, 1
	sb $s0, ($s2)
	subi $s2, $s2, 1
	sb $s0, ($s2)
	subi $s2, $s2, 1
	sb $s0, ($s2)
	subi $s2, $s2, 23
	subi $s1, $s1, 1
	bnez $s1, printAsteroidLoop
	jr $ra
	
##
#Procedimiento que aborta inmediatamente cualquier funcion si se llama a una funcion con un asteroide
#que no esta en el campo
noAsteroid:
	jr $ra
	
main:
	li $a3, 0  ##contador de puntos
	
loop:
	li $v0, 30
	syscall
	move $t8, $a0 #Se almacena el tiempo al comienzo del loop
	
	addi $a3, $a3, 1
	
	#se verifica si han pasado 5 segundos a traves del contador de puntaje
	div $t0, $a3, 25
	mfhi $t0 
	beqz $t0, createAsteroidTrue #Se crea un asteroide si han transcurrido 5 segundos
	j continueLoop
createAsteroidTrue:	
	jal createAsteroid
continueLoop:
	#Limpiamos para todos los asteroides
	la $t0, asteroid1InField #asteroide 1
	jal cleanAsteroid
	addi $t0, $t0, 5  #Asteroide 2
	jal cleanAsteroid
	addi $t0, $t0, 5  #Asteroide 3
	jal cleanAsteroid
	addi $t0, $t0, 5  #Asteroide 4
	jal cleanAsteroid

	
	#Se actualiza la informacion de todos los asteroides
	la $t0, asteroid1InField  #Asteroide 1
	jal updateAsteroid
	addi $t0, $t0, 5  #Asteroide 2
	jal updateAsteroid
	addi $t0, $t0, 5  #Asteroide 3
	jal updateAsteroid
	addi $t0, $t0, 5  #Asteroide 4
	jal updateAsteroid
	
	#Se insertan todos los asteroides en el grid
	la $t0, asteroid1InField  #Asteroide 1
	jal printAsteroid
	addi $t0, $t0, 5  #Asteroide 2
	jal printAsteroid
	addi $t0, $t0, 5  #Asteroide 3
	jal printAsteroid
	addi $t0, $t0, 5  #Asteroide 4
	jal printAsteroid

sleep:
	#Se calcula el delta temporal para el sleep
	li $t1, 200
	
	li $v0, 30
	syscall
	move $t9, $a0
	
	sub $t8, $t9, $t8
	sub $t8, $t1, $t8
	bltz $t8, printFrame
	
	li $v0, 32
	move $a0, $t8
	syscall
	
printFrame:
	la $a0, grid
	li $v0, 4
	syscall
	j loop