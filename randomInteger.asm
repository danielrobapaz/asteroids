# Generador de numeros random aleatorios
# La idea es que dado dos numeros, num1, tales
# que 0 <= num1 generar numeros aleatorios en 
# el intervalo [0, num1]

.text
	li	$v0, 30
	syscall			# cargamos en $a0 la hora en milisegundos.
	
	move 	$a1, $a0
	li 	$a0, 1
	li 	$v0, 40
	syscall			# seteamos la semilla
	
	li	$a1, 25
	li	$v0, 42
	syscall
	move 	$t0, $a0