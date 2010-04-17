	addq	$r1, 8, $r1
	addq	$r1, $r2, $r3
	addq	$r3, $r1, $r4
	stq 	$r3, 400($r3)
	addq  $r3, $r3, $r3
	addq  $r1, $r3, $r2
	stq   $r3, 440($r3)
	stq   $r1, 480($r3)
	ldq   $r4, 480($r3)
	stq		$r3, 560($r3)
	stq		$r1, 720($r3)
	#stq   $r1, 760($r3)
	call_pal		0x555
