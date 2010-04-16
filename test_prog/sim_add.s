	addq	$r1, 10, $r1
	addq	$r1, $r2, $r3
	addq	$r3, $r1, $r4
	addq	$r3, $r4, $r5
	call_pal		0x555
