	addq	$r1, 8, $r1
	addq	$r1, $r2, $r3
	addq	$r3, $r1, $r4
<<<<<<< .mine
	stq 	$r3, 4096($r3)
	stq   $r3, 6000($r3)
	stq   $r1, 8000($r3)
	ldq   $r4, 8000($r3)
=======
	stq 	$r3, 400($r3)
	stq   $r3, 600($r3)
	stq   $r1, 800($r3)
	ldq   $r4, 800($r3)
>>>>>>> .r235
	call_pal		0x555
