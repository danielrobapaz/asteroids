.kdata  # kernel data 
	s1: .word 0
	s2: .word 0 
	new_line: .asciiz "\n"    
	msg: .asciiz "interrupcion"
j main
.text  
.globl main 
 
 main:  
 	# Inicializamos el registro status

 	
 	# inicialimamos el registro couse
 	li	$a0, 0x8101
 	mtc0	$a0, $13
 	
 	# iniciliazamos el reciever control
 	li 	$a0, 0xffff0000
 	lw	$a1, ($a0)
 	ori	$a1, $a1, 2
 	sw	$a1, ($a0)
	li $t0, 10
here:	j here
	li $t0, 1
	

############### manejador de excepciones #######################
.ktext 0x80000180 # kernel code starts here    
	sw $a0, s1	# guardamos unos registros
	sw $v0, s2	
	
	mfc0	$k0, $13			# obtenemos el registro de causa
	srl	$a0, $k0, 2
	andi 	$a0, $a0, 0x7C			# obtenemos el excode
	bnez	$a0, ret			# si el excode es cero, hubo una excpecion
	
	# se redirige la interrupcion si proviene del teclado
	# (Keyboard: bit 8 de $13)
	andi	$k0, $k0, 0x0100
	bnez	$a0, teclado
	j endInterrupciones
	
teclado:
	# reinicia el bit 8 de $13
	mfc0	$k0, $13
	andi	$k0, $k0, 0xFEFF
	mtc0	$k0, $13
	
	lw	$a0, 0xFFF0004
	li	$v0, 11
	syscall
	
	j endInterrupciones
	
ret:
	mfc0	$k0, $14
	addi	$k0, $k0, 4
	mtc0	$k0, $14
	
endInterrupciones:
	mtc0 	$0, $13 	# se limpia cause
	lw 	$a0, s1
	lw	$v0, s2
	
	li	$k0, 0x8101
	mtc0	$k0, $12	# se restaura status
	
	eret
	
	
