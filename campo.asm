# Prueba de como almacenar el campo de juego


.data
	grid: .asciiz "#########################\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#                       #\n#########################"
	refresh: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	msg1: .asciiz "msj 1\n"
	msg2: .asciiz "msj 2\n"
	
.text
j main

# Muetra en pantalla el mapa del juego
showGame:


main: