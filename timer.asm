.data
	puntaje: .asciiz "puntaje:"
	score: .space	1		# espacio de un byte para guardar el puntaje
	
	
.text
	li	$t0, 1
	la	$t1, score
	sb	$t0, ($t1)
