# Tiempo de espera y refrescamiento
.data
	initMsg: .asciiz "alelimon alelimon\n"
	endMsg: .asciiz "el puente se ha caido"
.text
	li	$v0, 30
	syscall	#time
	move 	$s6, $a0
	
	###################################
	li $t1, 10000
loop:
	beqz $t1, endLoop
	la 	$t2, initMsg
	addi $t1, $t1, -1
	j loop
endLoop:
	###################################
	
	li	$v0, 30
	syscall	#time
	
	li	$t7, 200
	sub 	$s6, $a0, $s6		#tiempo transcurrido
	sub 	$a0, $t7, $s6		# tiempo restante
	li 	$v0, 32
	syscall #sleep
