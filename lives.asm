.data
	# Datos de la vida.
	liveExist:			.byte 	0
	livePos:			.byte 	0, 0	# byte 1 = live.row		 byte 2 = live.col
	liveSpeed:			.byte	0, 0	# byte 1 = live.speedX		 byte 2 = live.speedY
	liveSymbol:			.asciiz "@"

.text
j main
# Se crea una vida nueva
# Antes de crear la vida se verifica que no haya una vida existente ya.
# La vida se crea con una posicion inicial y una velocidad en x y y
# La posicion inicial debe ser algun borde del mapa
createLive: 
	# Verificamos que no hayan vidas
	lb	$t0, liveExist
	beqz	$t0, create	# no existe vida
	
	jr	$ra	# return, no se crea vida nueva
	
create:
	# ahora existe una vida
	li 	$t0, 1
	sb	$t0, liveExist
	
	# Obtenemos velocidad
	li 	$v0,30 
	syscall #time 
	move 	$a1,$a0 
	li 	$a0,1 
	li	$v0,40 
	syscall #set seed
	
	li	$v0, 42
	li	$a0, 1
	li	$a1, 3
	syscall	# random int range [0, 3)
	
	move	$t0, $a0
	la	$t1, liveSpeed	# velocidad en x
	sb	$t0, ($t1)
	
	li	$a0, 1
	syscall
	
	move	$t0, $a0
	li	$t0, 1
	sb	$t0, 1($t1)	# velocidad en y
	
	# Obtenemos la posicion 
	# Obtenemos una direccion random [0, 4)
	li	$a0, 1
	li	$a1, 4
	li	$v0, 42
	syscall
	move 	$t0, $a0	# $t0 = direccion
	
	li	$t1, 1
	li	$t2, 2
	li	$t3, 3
	beqz	$t0, dirFromLeft
	beq	$t0, $t1, dirFromUp
	beq	$t0, $t2, dirFromRigth
	beq	$t0, $t3, dirFromDown 	

dirFromLeft:
	# la nave sale desde x = 1 y y = random
	# no se modifica la velocidad
	la 	$t0, livePos
	li	$t1, 1	#pos en x
	sb	$t1, ($t0)
	
	# obtenemos posicion en Y
	li	$a0, 1
	li	$a1, 9
	li	$v0, 42
	syscall
	move	$t1, $a0	#pos en y
	sb	$t1, 1($t0)
	
	jr 	$ra
	
dirFromUp:
	# la nave sale desde x = random y y = 1
	# no se modifica la velocidad
	la	$t0, livePos
	li	$t1, 1
	li	$v0, 42
	sb	$t1, 1($t0)	# pos en y
	
	li	$a0, 1
	li	$a1, 24
	syscall
	move	$t1, $a0
	sb	$t1, ($t0)	# pos en x
	
	jr	$ra
	
dirFromRigth:
	# la nave sale desde x = 8 y y = random
	# la velocidad en x se cambia de signo
	la	$t0, livePos
	li	$t1, 23
	sb	$t1, ($t0)	# pos en x
	
	li	$a0, 1
	li	$a1, 9
	li	$v0, 42
	syscall
	move	$t1, $a0
	sb	$t1, 1($t0)	# pos en y
	
	# le invertmos el signo a la velocidad en x
	la	$t0, liveSpeed
	lb	$t1, ($t0)
	li	$t2, -1
	mul	$t1, $t1, $t2
	sb	$t1, ($t0)
	
	jr $ra
	
dirFromDown:
	# la nave sale desde x = random y y = 24
	# la velocidad en y se cambia de signo
	la	$t0, livePos
	li	$t1, 8		# pos en y
	sb	$t1, 1($t0)
	
	li	$a0, 1
	li	$a1, 22
	li	$v0, 42
	syscall
	move	$t1, $a0
	addi	$t1, $t1, 1
	sb	$t1, ($t0)	# pos en x
	
	la	$t0, liveSpeed
	lb	$t1, 1($t0)
	li	$t2, -1
	mul	$t1, $t1, $t2
	sb	$t1, 1($t0)
	
	jr	$ra	
	
	
# Se actualiza la posicion de la vida en el campo
# Dada la posicion x y y de la vida se busca esa posicion en 
# el string y se escribe la vida
cleanLive:
	lb	$t0, liveExist
	beqz	$t0, endCleanLive
	la 	$t0, livePos
	lb	$t1, ($t0)		# $t1 = live.x
	addi	$t0, $t0, 1
	lb 	$t0, ($t0) 		# $t0 = live.y
	
	li 	$t2, 26
	mul	$t0, $t0, $t2
	add 	$t1, $t1, $t0		# $t1 = posicion en donde se escribira un espacio en blanco
	
	la	$t0, grid
	add 	$t0, $t0, $t1
	
	la	$t1, blankSpace
	lb 	$t1, ($t1)
	sb 	$t1, ($t0)		# es escribe un espacio en blanco

endCleanLive:

	jr 	$ra

# Se busca la nueva posicion de la vida dentro del mapa.
updateLive:
	lb	$t0, liveExist
	beqz	$t0, endUpdateLive
	
	la	$t0, livePos
	lb	$t1, ($t0)	# live.posX
	lb	$t2, 1($t0)	# live.posY
	
	la	$t0, liveSpeed
	lb	$t3, ($t0)	# live.speedX
	lb	$t4, 1($t0)	# live.speedY
	
	add	$t1, $t1, $t3	# nueva posicion en X
	add	$t2, $t2, $t4	# nueva posicion en Y
	
	# Verificamos si la vida no se salio del mapa
	# verificamos que no se salio en el eje X
	li 	$t3, 23
	blez	$t1, deleteLive
	bgt	$t1, $t3, deleteLive

	 # verificamos que no se salio del eje Y
	 li	$t3, 7
	 blez	$t2, deleteLive
	 bgt	$t2, $t3, deleteLive
	 
	 j updateLivePos
	 
deleteLive:
	# se elimina la vida
	li	$t1, 0
	sb	$t1, liveExist
	j 	endUpdateLive
	
updateLivePos:
	la	$t0, livePos
	sb	$t1, ($t0)
	sb	$t2, 1($t0)
	
endUpdateLive:
	jr	$ra
	

	