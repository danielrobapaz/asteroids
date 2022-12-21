# Proyecto 2 - Asteroids
# Implementacion del juego de arcado 'Astroids' simplificada
# Integrante:
#	Daniel Robayo, 18 - 11086
#	Santiago Finamore, 18 - 10125


.data
	# datos del mapa
	grid: 			.asciiz "#########################\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#########################\n"
	scoreStr:		.asciiz	"Puntaje: "
	livesStr:		.asciiz "\nVidas: "
	breakLine:		.asciiz "\n"
	blankSpace:		.asciiz " "
	refresh:		.asciiz "\n\n\n\n\n\n\n\n\n\n\n\n"
	gameOverStr:		.asciiz "Game Over. Puntaje final: "
	
.text
j main

# Input: No recibe argumentos
# Output: Muestra en pantalla el mapa con el estado actual del juego
printGrid:
	la 	$a0, grid
	li	$v0, 4
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
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	cleanLive		# se borra la posicion anterior del jugador
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	# Actualizamos la posiccion e los elementos
	addi 	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal 	updatePlayer		# se actualiza la nueva posicion del jugador 
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal 	updateLive		# se actualiza la nueva posicion de la vida
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	
	######################### se escribe en el campo la vida
	# verificamos que haya una vida
	lb	$t0, liveExist
	beqz	$t0, printPlayer
	
	la	$t0, livePos
	lb	$t1, ($t0)	# live.x
	lb	$t2, 1($t0)	# live.y
	
	li 	$t0,  26
	mul	$t2, $t2, $t0
	add	$t1, $t1, $t2		# $t1 = posicion en donde se escribira la vida
	
	la	$t0, grid
	add	$t0, $t0, $t1,
	lb	$t1, liveSymbol
	sb	$t1, ($t0)		

printPlayer: 	
	######################### se escribe en el campo la nave
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
	
	# Verificamos colisiones
	lb	$t3, ($t2)
	lb	$t4, blankSpace
	bne	$t3, $t4, collisions	# si el caracter en donde se imprimira la nave no es un espacio en blanco se revisa la colission
	sb 	$t0, ($t2)
	jr 	$ra

collisions:
	# verificamos las colisiones
	# en $t3 se encuentra el byte del que ocasiono la collision
	lb	$t4, liveSymbol
	beq	$t3, $t4, collisionLive
	#
	# aqui iria lo de la nave
	#
	#
	#
	jr	$ra	# la colision ocurrio con la misma nave
collisionLive:
	# se le suma una vida al jugador, se limpia la vida y se elimina la vida existente
	la	$t3, playerLives
	lb	$t4, ($t3)
	addi	$t4, $t4, 1
	sb	$t4, ($t3)
	
	la	$t3, liveExist
	lb	$t4, ($t3)
	addi	$t4, $t4, -1
	sb	$t4, ($t3)
	
	addi	$sp, $sp, -4
	sw	$ra ($sp)
	jal 	cleanLive
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	
	jr 	$ra
	
	
	
# Se actualiza el string que corresponde al puntaje y las vidas del jugador
# Input: Se espera el puntaje en el registro $a3
# Output: None
printScore:
	# imprimos un el puntaje
	la	$a0, scoreStr
	li	$v0, 4
	syscall	 
	move	$a0, $a3
	li	$v0, 1
	syscall
	
	# Imprimimos las vidas del jugador
	la	$a0, livesStr
	li	$v0, 4
	syscall
	lb	$a0, playerLives
	li	$v0, 1
	syscall
	
	# imprimos un salto de linea
	la	$a0, breakLine
	li	$v0, 4
	syscall
	
	jr	$ra
	

# Se muestra una sucecion de saltos de linea para simular un refrescamiento de la consola
# Input: No se espera ningun registro
# Output: Una sicecion de saltos de linea
printRefresh:
	la	$a0, refresh
	li	$v0, 4
	syscall
	
	jr 	$ra
	
	
##################### main ###############################
main:	
	# inicializamos el manejador de interrupciones
	# Inicializamos cause
	li	$a0, 0x8101
	mtc0	$a0, $13
	
	# inicializamos reciever control
	li	$a0, 0xffff0000
	lw	$a1, ($a0)
	ori	$a1, $a1, 2
	sw	$a1, ($a0)
	
	lw 	$a1, 8($a0)
	ori	$a1, $a1, 1
	sw	$a1, 8($a0)
	
	li	$a3, 0		# inicializamos el puntaje
	
	jal	updatePlayer
	jal 	printScore
	jal 	printGrid
loop:
	addi	$a3, $a3, 1		# aumentamos el puntaje
	
	li	$t0, 300
	div	$a3, $t0
	mfhi	$t0
	bnez	$t0, continueLoop
	
	jal 	createLive
	
continueLoop:
	# Inicializamos el temporizador
	li	$v0, 30
	syscall			# time
	move	$s6, $a1
	
	jal 	updateGrid			
	jal 	printScore
	jal 	printGrid
	jal 	printRefresh	
	
	li	$v0, 30
	syscall			# time
	sub 	$s6, $s6, $a1	# elapsed time
	
	li	$t7, 200
	sub	$a0, $t7, $t6
	bltz	$a0, loop	# si el tiempo restante es negativo se hace la iteracion	
				# de inmediato
				
	li	$v0, 32
	syscall			#sleep
	
	# Verificamos si le quedan vidas al jugador
	lb	$t0, playerLives
	beqz	$t0, endLoop

	j loop
endLoop:
	la	$a0, gameOverStr
	li	$v0, 4
	syscall
	move	$a0, $a3
	li	$v0, 1
	syscall
	li 	$t0, 1
	
# Incluimos los demas archivos
.include "controlPlayer.asm"
.include "lives.asm"