.data

grid: .asciiz "#########################\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#########################\n"
asteroidChar: .asciiz "L"
asteroidInField: .space 1 #Indica si hay o no un asteroide en el campo
asteroidPosX: .space 1 #Posicion en X del asteroide, varia entre 1 y 20
asteroidPosY: .space 1 #Posicion en Y del asteroide, varia entre 3 y 8
asteroidSpX: .space 1 #Velocidad del asteroide en X, varia entre -2 y 2
asteroidSpY: .space 1 #velocidad del asteroide en Y, varia entre -1 y 1

	
.text

#Objetivo del programa: Generar continuamente un unico asteroide hasta que se interrumpa el programa
asteroidLoop:
	
	li $v0, 30 #Se almacena el timestamp del inicio del loop
	syscall
	move $t0, $a0
	
	lb $t1, asteroidInField   #Se verifica si hay o no un asteroide en pantalla
	beqz $t1, createAsteroid  #Si no hay ninguno, se genera el asteroide
	
	#En caso contrario, se actualiza la posicion del asteroide en el tablero
	lb $t1, asteroidPosX
	lb $t2, asteroidPosY
	
	#Se limpia la posicion anterior del asteroide en pantalla
	jal cleanAsteroid
	
	#Se suma a la posicion conseguida la velocidad del asteroide en ambos ejes
	lb $t3, asteroidSpX
	lb $t4, asteroidSpY
	
	add $t1, $t1, $t3
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
	
	sb $t1, asteroidPosX    #Se guardan las nuevas posiciones en memoria
	sb $t2, asteroidPosY
	
continueAsteroidLoop:
	
	#Se procede a digerir los datos disponibles sobre el asteroide en memoria
	lb $t1, asteroidPosX
	lb $t2, asteroidPosY
	
	#Se procede a imprimir el asteroide
	jal printAsteroid
	
sleep:
	#Se calcula el delta temporal para el sleep
	li $t1, 200
	
	li $v0, 30
	syscall
	move $t2, $a0
	
	sub $t0, $t2, $t0
	sub $t0, $t1, $t0
	bltz $t0, printFrame  #Si el frame tardo mas de 0.2s en generarse se refresca automaticamente
	
	li $v0, 32  #En caso contrario se duerme hasta que se cumplan los 0.2s
	move $a0, $t0
	syscall
	
printFrame:
	la $a0, grid
	li $v0, 4
	syscall
	j asteroidLoop
	
	

##########################################################################################################################################
#######################################################Fuciones###########################################################################
##########################################################################################################################################	


##
#Funcion que genera los datos de un nuevo asteroide. Genera posiciones iniciales en X e Y para el asteroide
#y le asigna velocidades pseudoaleatorias en dichos ejes. También marca el asteroide como existente en el 
#campo.
createAsteroid:

	li $t1, 1  #Se marca el asteroide como existente
	sb $t1, asteroidInField
	
	li $v0, 42   #Se escoge aleatoriamente una posición en X entre 1 y 20 (Campo jugable)
	li $a1, 19
	syscall
	addi $a0, $a0, 1
	move $t1, $a0  #Se guardan las posiciones elegidas para asistir en la escogencia de velocidades
	sb $a0, asteroidPosX  #Se guarda en memoria
	
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
	sb $a0, asteroidPosY
	
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
	sb $a0, asteroidSpX  #Se almacena la velocidad  en X calculada
	
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
	sb $a0, asteroidSpY
	j continueAsteroidLoop
	
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
	sb $a0, asteroidPosY
	j continueCreateAsteroid


##
#Procedimiento que limpia el los caracteres ocupados por un asteroide en pantalla.
#Necesario para que los asteroides no dejen rastro al moverse.
cleanAsteroid:

	li $s0, 32  #ASCII para " "
	li $s1, 3  #Contador del ciclo
	move $s2, $t1  #Ubicacion en X
	move $s3, $t2  #Ubicacion en Y
	
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
	
	li $s0, 76  #ASCII para "L"
	li $s1, 3  #Contador del ciclo
	move $s2, $t1
	move $s3, $t2
	
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
	
removeAsteroid:
	li $t4, 0
	sb $t4, asteroidInField
	j sleep
