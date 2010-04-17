	addq	$r1, 16, $r1
	addq	$r1, $r2, $r3
	addq	$r3, $r1, $r4
	stq 	$r3, 400($r3)
	addq  $r3, $r3, $r3
	addq  $r1, $r3, $r2
<<<<<<< .mine
	 stq   $r3, 600($r3)
	 stq   $r1, 800($r3)
	 ldq   $r4, 800($r3)
	 stq		$r4, 1600($r3)
	 stq		$r4, 1200($r3)
	addq  $r3, $r3, $r3
	addq  $r1, $r3, $r2
=======
	stq   $r3, 440($r3)
	stq   $r1, 480($r3)
	ldq   $r4, 480($r3)
	stq		$r3, 560($r3)
	ldq   $r3, 560($r3)
	stq		$r1, 720($r3)
	stq   $r1, 2024($r0)
>>>>>>> .r248
	call_pal		0x555
