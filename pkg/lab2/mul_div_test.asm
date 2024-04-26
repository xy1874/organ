.text
MAIN:
	lui a7, 0xFFFF1

	# test0
	lui  t0, 0x40000
	ori  t0, t0, 0x7B
	ori	 t1, zero, 0x165
	mul  a0, t0, t1		# 0x4000_007B*0x165 = 0x59_4000_AB87
	sw   a0, 0(a7)
	mulh a1, t0, t1		# 0x59
	sw   a1, 0(a7)
	div  a2, t0, t1		# 0x4000_007B/0x165 = 0x2D_E4C0
	sw   a2, 0(a7)
	rem  a3, t0, t1		# 0x4000_007B%0x165 = 0xBB
	sw   a3, 0(a7)

	# test1
	ori  t0, zero, -26
	ori	 t1, zero, 5
	mul  a0, t0, t1		# -26*5 = 0xFFFF_FF7E
	sw   a0, 0(a7)
	mulh a1, t0, t1		# 0xFFFF_FFFF	
	sw   a1, 0(a7)
	div  a2, t0, t1		# -26/5 = 0xFFFF_FFFB
	sw   a2, 0(a7)
	rem  a3, t0, t1		# -26%5 = 0xFFFF_FFFF
	sw   a3, 0(a7)

	# test2
	lui  t0, 0x45670
	ori  t0, t0, 0x64
	ori	 t1, zero, -13
	mul  a0, t0, t1		# 0x4567_0064*(-13) = 0xFFFF_FFFC_79C4_FAEC
	sw   a0, 0(a7)
	mulh a1, t0, t1		# 0xFFFF_FFFC
	sw   a1, 0(a7)
	div  a2, t0, t1		# 0x4567_0064/(-13) = 0xFAA9_4EBE
	sw   a2, 0(a7)
	rem  a3, t0, t1		# 0x4567_0064%(-13) = 0xA
	sw   a3, 0(a7)

	# test3
	ori  t0, zero, -306
	ori	 t1, zero, -28
	mul  a0, t0, t1		# (-306)*(-28) = 0x2178
	sw   a0, 0(a7)
	mulh a1, t0, t1		# 0x0
	sw   a1, 0(a7)
	div  a2, t0, t1		# (-306)/(-28) = 0xA
	sw   a2, 0(a7)
	rem  a3, t0, t1		# (-306)%(-28) = 0xFFFF_FFE6
	sw   a3, 0(a7)
	
END_LOOP:
	addi zero, zero, 0
	jal  zero, END_LOOP
