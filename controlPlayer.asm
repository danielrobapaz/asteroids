.kdata  # kernel data 
	s1: .word 0
	s2: .word 0 

.data
	# datos sobre la nave
	rotacionesNave: 	.asciiz "A>V<"
	playerPos: 		.byte 5, 12 	# (row, col)
	playerSpeed: 		.byte 0		# velocidad de la nave (> 0 aunemnta fila o columna, < 0 disminuye fila o col)	
	playerDirection: 	.byte 0		# direccion de la nave
	playerLives: 		.byte 3		# vidas del jugador

# Sobreecribimos el manejador de excepciones 
.ktext	0x80000180
beginHandler:
	# Almancenamos unos registros en memoria del kernel
	sw	$a0, s1
	sw	$v0, s2
	
	# Vemos el registro causa para determinar si hubo una interrupcion
	mfc0	$a0, $13
	andi	$a0, 0x0000007C	# enmascaramos el exCode
	bnez	$a0, ret	
	
	# redirigimos las interrupciones del teclado
	mfc0	$k0, $13	# obtenemso cause
	andi	$k0, 0x00000400	# revsamos si la interrupcion fue de teclado
	bnez	$k0, ret
	
	# reiniciamos el bit 8 de cause
	mfc0	$k0, $13
	andi	$k0, 0xfeff
	mtc0 	$k0, $13
	
	lw	$a0, 0xffff0004	# obtenemos la tecla presionada del jugador
	
	beq	$a0, 'w', controlAcelerate
	beq	$a0, 'W', controlAcelerate
	
	beq	$a0, 's', controlBreak
	beq	$a0, 'S', controlBreak
	
	beq	$a0, 'a', controlRotateLeft
	beq	$a0, 'A', controlRotateLeft
	
	beq	$a0, 'd', controlRotateRigth
	beq	$a0, 'D', controlRotateRigth
	
	j ret	# se presiono otra tecla se omite


# Se efectua el aumento de la velocidad del jugador. El maximo de velocidad es 2.
# Si la velocidad ya es igual a 2 no se ascelere y se omite el comando
controlAcelerate:	
	la	$k0, playerSpeed
	lb 	$k0, 0($k0)
	li	$k1, 3
	beq	$k0, $k1, ret
	addi	$k0, $k0, 1
	sb	$k0, playerSpeed
	j ret


# Se efectua la disminucion de la velocidad del jugador. El minimo de velocidad es 0.
# Si la velocidad ya es igual a 0 no se ascelere y se omite el comando
controlBreak:	
	la	$k0, playerSpeed
	lb	$k1, ($k0)
	beqz	$k1, ret
	addi	$k1, $k1, -1
	sb	$k1, playerSpeed
	j ret


# Se rota la nave del jugados 90 grados a la izquirda. 
controlRotateLeft:	
	la	$k1, playerDirection
	lb	$k0, ($k1)
	beqz	$k0, controlRotateLeftReset
	addi	$k0, $k0, -1
	sb	$k0, playerDirection
	j ret
	
controlRotateLeftReset:
	li	$k0, 3
	sb	$k0, playerDirection
	j ret



# Se rota la nave 90 grados a la derecha
controlRotateRigth:
	la	$k1, playerDirection
	lb	$k0, ($k1)
	li	$k1, 3
	beq	$k0, $k1, controlRotateRigthReset
	addi	$k0, $k0, 1
	sb	$k0, playerDirection	
	j ret
	
controlRotateRigthReset:
	li	$k0, 0
	sb	$k0, playerDirection
	j ret
	
	
ret:

	mfc0 	$k0, $14
	#addi	$k0, $k0, 4
	mtc0	$k0, $14
	
endHandler:
	 # recuperamos los registro
	 lw	$a0, s1
	 lw	$v0, s2
	 
	 eret
