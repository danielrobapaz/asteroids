# Prueba de el input. La idea es que se capte el input un caracter a la vez y de manera 
# automatica
# s = 115
# w = 119
# d = 100
# a = 97
.data 
	input: .space 2 # espacio para el input
	bLine: .asciiz "\n"
	rotacionesNave: .asciiz "A>V<"
	acelerarStr: .asciiz "acelerar"
	frenarStr: .asciiz "frenar"
.text
la $t0, input
li $t1, 0
whileTrue:
	la	$a0, input		# leemos letra del usuario
	li	$a1, 2
	li	$v0, 8
	syscall	
	
	lb	$t2, ($t0)		# guradamos lo que el usuario ingreso
	
	li $t3, 97			# ascii a
	li $t4, 100			# ascii d
	li $t5, 115			# ascii s
	li $t6, 119			# ascii w
	
	beq $t2, $t3, rotarIzq
	beq $t2, $t4, rotarDer
	beq $t2, $t5, frenar
	beq $t2, $t6, acelerar
	
############################################################################
rotarIzq:
	la 	$t3, rotacionesNave
	beqz 	$t1, resetearRotarIzq
	addi 	$t1, $t1, -1		# restamos uno en el apuntador
	j imprimirRotacionIzq
resetearRotarIzq:
	li $t1, 3

imprimirRotacionIzq:
	add 	$t3, $t3, $t1
	lb $a0, ($t3)
	li $v0, 11
	syscall	
	j whileTrue
###########################################################################	
rotarDer:
	la 	$t3, rotacionesNave
	li 	$t2, 3
	beq 	$t1, $t2, resetearRotarDer
	addi 	$t1, $t1, 1
	j imprimirRotacionDer
resetearRotarDer:
	li 	$t1, 0
imprimirRotacionDer:
	add	$t3, $t3, $t1
	lb 	$a0, ($t3)
	li 	$v0, 11
	syscall
	j whileTrue	
	
##################################################################3
frenar:
	la $a0, frenarStr
	li $v0, 4
	syscall
	j whileTrue
###################################################################
acelerar:			
	la $a0, acelerarStr
	li $v0, 4
	syscall
	j whileTrue
