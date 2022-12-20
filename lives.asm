.data
		# Datos de la vida.
	liveExist:			.byte 	0
	livePos:			.space 	2	# byte 1 = live.row		 byte 2 = live.col
	liveSpeed:			.space	2	# byte 1 = live.speedX		 byte 2 = live.speedY
	livesDireccion:			.byte 	0
	
.text
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
	
	move	$a0, $t0
	la	$t1, liveSpeed	# velocidad en x
	sb	$t0, ($t1)
	
	li	$a0, 1
	syscall
	
	move	$a0, $t0
	sb	$t0, 1($t1)	# velocidad en y
	
	# Obtenemos la posicion 
	# Obtenemos 
	jr 	$ra