.data
	msg: .asciiz "hola\n"
	prueba: .word 1234
.text
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
	ori	$a1, $a1, 2
	sw	$a1, 8($a0)
	
	lui	$t0, 0xffff
	lw	$s2, prueba
	sw	$s2, 12($t0)
	
	li	$t0, 0
	addi	$t0, $t0 4