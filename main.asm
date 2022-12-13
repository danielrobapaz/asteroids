# Proyecto 2 - Astroids
# Implementacion del juego de arcado 'Astroids' simplificada
# Integrante:
#	Daniel Robayo, 18 - 11086
#	Santiago Finamore, 18 - 10125


.data
	grid: .asciiz "#########################\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#########################\n"
	
	# datos sobre la nave
	rotacionNave: .asciiz "A>V<"
	playerPos: .byte 5, 12 	# (row, col)
	
.text
j main

# Input: No recibe argumentos
# Output: Muestra en pantalla el mapa con el estado actual del juego
printGrid:
	la 	$a0, grid
	li 	$v0, 4
	syscall				# print
	
	jr $ra


# Dadas las nuevas posiciones de los elementos en la pantalla
# se imprme en pantalla los cambios durante un refrescamiento 
# del programa
# Input: no se reciben argumentos
updateGrid:
	la 	$t0, playerPos
	lb 	$t1, ($t0)	# $t1 = player.row
	addi 	$t0, $t0, 1
	lb	$t2, ($t0)	# $t2 = player.col
	
	li 	$t0, 26
	mul	$t0, $t0, $t1
	add 	$t1, $t0, $t2		# $t1 = posicion en donde se escribira la nave del jugador
	
	la 	$t0, grid
	add 	$t0, $t0, $t1 
	sb 	$t1, ($t0)
	
	jr 	$ra
main:	
	jal 	printGrid
	jal 	updateGrid			# actualizamos el mapa
	jal 	printGrid			# imprimimos el mapa