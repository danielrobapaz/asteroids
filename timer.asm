.kdata  # kernel data 
	s1: .word 0
	s2: .word 0 
	girarDer: .asciiz "girar der 90 grados\n"
	girarIzq: .asciiz "girar izq 90 grados\n"
	acelerar: .asciiz "acelerar\n"
	frenar:	 .asciiz "frenar\n"
	
.data
	
.text
main:
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
	
loop: j loop
	li $v0, 10
	syscall	#exit program
	
	
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
	
	beq	$a0, 'w', controlAcelerar
	beq	$a0, 'W', controlAcelerar
	
	beq	$a0, 's', controlFrenar
	beq	$a0, 'S', controlFrenar
	
	beq	$a0, 'a', rotarIzq
	beq	$a0, 'A', rotarIzq
	
	beq	$a0, 'd', rotarDer
	beq	$a0, 'D', rotarDer
	
	j ret	# se presiono otra tecla se omite
	
controlAcelerar:
	la	$a0, acelerar
	li	$v0, 4
	syscall
	j ret
	
controlFrenar:
	la	$a0, frenar
	li	$v0, 4
	syscall
	j ret
	
rotarIzq:
	la	$a0, girarIzq
	li	$v0, 4
	syscall
	j ret
	
rotarDer:
	la	$a0, girarDer
	li	$v0, 4
	syscall
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
	
	
.data
	adios: .word 199