	addq	$r1, 8, $r1
	addq	$r1, $r2, $r3
	addq	$r3, $r1, $r4
	stq 	$r3, 4096($r3)
	stq   $r3, 6000($r3)
	stq   $r1, 8000($r3)
	ldq   $r4, 8000($r3)
	call_pal		0x555
