.data
	array: .word   0xA, 0x123, 0xFF
    str:   .string "Hello World!\n"

.macro push %a
	addi	sp, sp, -4
	sw 		%a, 0(sp) 
.end_macro

.macro pop %a
	lw 		%a, 0(sp) 
	addi	sp, sp, 4
.end_macro

.text
MAIN:
	lui  	s0, 0x10010     # 将数据段基地址赋值给s0寄存器

    lw   	t0, 0x0(s0)     # 读取array[0]到t0寄存器
    lw   	t1, 0x4(s0)     # 读取array[1]到t1寄存器
    lw   	t2, 0x8(s0)     # 读取array[2]到t2寄存器
    
	addi 	a0, s0, 12      # 将字符串str的基地址赋值给a0寄存器  
	jal		ra, FUNC
	
	ori     a7, zero, 10
	ecall

FUNC:
	push	t1
	# ......
	pop 	t1
	jalr 	zero, ra, 0		# jalr zero, 0(ra) OR ret OR jr ra
