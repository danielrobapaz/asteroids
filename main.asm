# Proyecto 2 - Asteroids
# Implementacion del juego de arcado 'Astroids' simplificada
# Integrante:
#	Daniel Robayo, 18 - 11086
#	Santiago Finamore, 18 - 10125


.data
	# datos sobre la nave
	rotacionesNave: 	.asciiz "A>V<"
	playerPos: 		.byte 5, 12 	# (row, col)
	playerSpeed: 		.byte 0		# velocidad de la nave (> 0 aunemnta fila o columna, < 0 disminuye fila o col)	
	playerDirection: 	.byte 0		# direccion de la nave
	playerLives: 		.byte 3		# vidas del jugador
	
	# datos del mapa
	grid: 			.asciiz "#########################\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#########################\n"
	blankSpace:		.asciiz " "
	input:			.space 2
	
.text
j main

# Input: No recibe argumentos
# Output: Muestra en pantalla el mapa con el estado actual del juego
printGrid:
	la 	$a0, grid
	li 	$v0, 4
	syscall				# print
	
	jr $ra

# Se actualiza la posicion de la nave
# Input: no se reciben argumentos
updatePlayer:
	la 	$t0, playerPos
	lb 	$t1, ($t0)		# $t1 = player.row
	addi	$t0, $t0, 1
	lb	$t2, ($t0)		# $t2 = player.cols
	
	lb 	$t0, playerSpeed	# $t0 = player.speed
	lb	$t3, playerDirection	# $t3 = player.direction
	
	li	$t4, 1			
	li	$t5, 2
	li	$t6, 3
	
	beqz	$t3, upMove		# la nave va hacia arriba
	beq	$t3, $t4, rigthMove	# la nave se mueve hacia la derecha
	beq	$t3, $t5, downMove	# la nave se mueve hacia abajo
	beq	$t3, $t6, leftMove	# la nave se mueve hacia la izq
	
upMove:					# se actualiza la nueva posicion del jugador
					# se efectua el warp en caso de que $t1 <= -1
	li	$t3, -1		
	mul	$t0, $t0, $t3
	add	$t1, $t1, $t0
	li	$t3, 1
	bge 	$t1, $t3, endUpdatePlayer	# si $t1 >= 0 no se efectua warp
	li 	$t3, 8
	add	$t1, $t3, $t1
	j endUpdatePlayer
	
rigthMove: 				# se acutaliza la nueva poscicion del jugador
					# se efectua el warp en caso de que $t2 > 23
	add	$t2, $t2, $t0
	li	$t3, 22
	ble	$t2, $t3, endUpdatePlayer
	sub	$t2, $t2, $t3
	j endUpdatePlayer
	
downMove:				# se acualiza la nueva posicion del jugador
					# se efectua warp en caso de que $t1 > 8
	add	$t1, $t1, $t0
	li	$t3, 8
	ble	$t1, $t3, endUpdatePlayer
	sub	$t1, $t1, $t3
	j endUpdatePlayer
	
leftMove:				# se acutaliza la nueva posicion del jugador
					# se ejecuta el warp en caso de que $t2 < 0
	li	$t3, -1
	mul	$t0, $t0, $t3
	add 	$t2, $t2, $t0
	li	$t3, 1
	bge	$t2, $t3, endUpdatePlayer
	li	$t3, 22
	add	$t2, $t3, $t2
	j endUpdatePlayer
	 
endUpdatePlayer:
	la	$t0, playerPos
	sb	$t1, ($t0)
	addi	$t0, $t0, 1
	sb	$t2, ($t0)
	
	jr	$ra
	
	
# Se limpia del campo la posicion acual de jugador
cleanPlayer: 
	la 	$t0, playerPos
	lb	$t1, ($t0)		# $t1 = player.row
	addi	$t0, $t0, 1
	lb 	$t0, ($t0) 		# $t0 = player.col
	
	li 	$t2, 26
	mul	$t1, $t1, $t2
	add 	$t1, $t1, $t0		# $t1 = posicion en donde se escribira un espacio en blanco
	
	la	$t0, grid
	add 	$t0, $t0, $t1
	
	la	$t1, blankSpace
	lb 	$t1, ($t1)
	sb 	$t1, ($t0)		# es escribe un espacio en blanco

	jr 	$ra
	
# Se recibe un input que puede ser a,w,s,d o p. Dependiendo del input recibido
# se modifica en memoria la rotacion de la nave y su velocidad.
# Input: No se espera ningun registro
controlPlayer:
	la 	$a0, input
	li 	$a1, 2
	li 	$v0, 8
	syscall			# leer input
	
	lb 	$t0, ($a0)
	
	li 	$t1, 97		# ascii a
	li	$t2, 100	# ascii d
	li	$t3, 115	# ascii s
	li 	$t4, 119	# ascii w
	
	la	$t5, playerDirection
	lb	$t6, ($t5)	# $t6 = player.direction de rotacion
	
	beq	$t0, $t1, controlRotateLeft
	beq	$t0, $t2, controlRotateRigth
	beq	$t0, $t3, controlBreak
	beq	$t0, $t4, controlAcelerate
	
	jr 	$ra		# no se hace nada
	
controlRotateLeft:
	beqz	$t6, controlRotateLeftReset
	addi	$t6, $t6, -1
	sb	$t6, ($t5)
	j endControlPlayer
controlRotateLeftReset:
	li 	$t6, 3
	sb	$t6, ($t5)	# escribimos en memoria
	j endControlPlayer
	
controlRotateRigth:
	li	$t1, 3
	beq 	$t6, $t1, controlRotateRigthReset
	addi	$t6, $t6, 1
	sb	$t6, ($t5)
	j endControlPlayer
	
controlRotateRigthReset:
	li 	$t6, 0
	sb	$t6, ($t5)	# escribimos en memoria
	j endControlPlayer
	 
controlAcelerate: 
	la	$t0, playerSpeed
	lb	$t1, ($t0)
	li	$t2, 3
	beq 	$t1, $t2, endControlPlayer	# no se puede acelerar mas
	addi	$t1, $t1, 1
	sb	$t1, ($t0)
	j endControlPlayer
	
controlBreak:
	la	$t0, playerSpeed
	lb	$t1, ($t0)
	beqz	$t1, endControlPlayer	# no se puede frenar mas
	addi	$t1, $t1, -1
	sb 	$t1, ($t0)
	j endControlPlayer

endControlPlayer:
	jr 	$ra
# Dadas las nuevas posiciones de los elementos en la pantalla
# se imprme en pantalla los cambios durante un refrescamiento 
# del programa
# Funciona en 3 etapas.
#	i) se sobreescriben en el campo las posiciones anteriores de cada elemento usando espacios en blanco
#	ii) se actualizan las posiciones de cada elemento usando la representacion correspondiente
#	iii) se actualiza el campo con las nuevas posiciones
# Input: no se reciben argumentos
updateGrid:
	# Limpiamos el campo
	addi 	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal 	cleanPlayer		# se borra la posicion anterior del jugador del tablero
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	# Actualizamos la posiccion e los elementos
	addi 	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal 	updatePlayer		# se actualiza la nueva posicion del jugador 
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	la 	$t0, playerPos
	lb 	$t1, ($t0)		# $t1 = player.row
	addi 	$t0, $t0, 1
	lb	$t2, ($t0)		# $t2 = player.col
	
	li 	$t0, 26
	mul	$t0, $t0, $t1
	add 	$t1, $t0, $t2		# $t1 = posicion en donde se escribira la nave del jugador
	
	la 	$t0, rotacionesNave
	lb	$t2, playerDirection
	add 	$t0, $t0, $t2
	lb	$t0, ($t0)		# caracter de la rotacion de la nave
	
	la 	$t2, grid
	add 	$t2, $t2, $t1 
	sb 	$t0, ($t2)
	
	jr 	$ra

##################### main ###############################
main:	
	li $t9, 100
	jal 	printGrid
	
loop:
	beqz $t9, endLoop
	
	addi $t9, $t9, -1
	
	jal	controlPlayer
	jal 	updateGrid			
	jal 	printGrid		
	
	li	$a0, 200
	li	$v0, 32
	syscall
	
	j loop
endLoop:
	li 	$t0, 1
	
