
.include "ARM_System_Mem_Map.h"
.include "ARM_System_Misc.h"

.text
	.align 4
start: 
                B           reset        /* 0x00 Reset handler */
undefvec:
                B           .            /* 0x04 Undefined Instruction */
swivec:
                B           softirq      /* 0x08 Software Interrupt */
pabtvec:
                B           .            /* 0x0C Prefetch Abort */
dabtvec:
                B           .            /* 0x10 Data Abort */
rsvdvec:
                B           .            /* 0x14 reserved  */
irqvec:
                B           IRQ_handler  /* 0x18 IRQ	 */
fiqvec:               			   
	           	 B	   		 . 			  /* 0x1C FIQ	*/


reset:


   LDR   R5,   =ARM_System_GPIO_Base
   LDR   R13,  =sys_stack  
   MOV   R1,   #1  
   MOV   R2,   #1  



	ldr r2, =ARM_System_GPIO_Base
	mov r0, #(SEG_0)
	str r0, [r2, #GPIO_HEX0]
	str r0, [r2, #GPIO_HEX1]
	str r0, [r2, #GPIO_HEX2]
	str r0, [r2, #GPIO_HEX3]
	str r0, [r2, #GPIO_HEX4]
	str r0, [r2, #GPIO_HEX5]
	mov r0, #(SEG_)
	str r0, [r2, #GPIO_HEX6]
	mov r0, #(SEG_A)
	str r0, [r2, #GPIO_HEX7]


	ldr r3, =ARM_System_Timer_Base
	ldr r1, =Timer_Limit

	str r1, [r3, #0] /*Timver R0 register set F000F */
	ldr r13, =sys_stack   /* set stack pointer */

loop:
	ldr r1, [r3, #0x200] /* read status register */
	cmp r1, #1
	beq sec0
	b loop
	
sec0:
	ldr r0, =data	/* r0 = pointer to data block */
	ldr r1, [r0, #0]	/* r1 = data[0] : sec0 */
	add r1, r1, #1
	cmp r1, #10
	moveq r1, #0
	str r1, [r0, #0]
	bleq sec1
	ldr r1, [r0, #0]
	bl trans
	str r1, [r2, #GPIO_HEX0]
	b loop
	
sec1:
	sub sp, sp, #4
	str lr, [sp]    	/* push */
	ldr r1, [r0, #4]	/* r1 = data[1] : sec1 */
	add r1, r1, #1
	cmp r1, #6
	moveq r1, #0
	str r1, [r0, #4]
	bleq min0
	ldr r1, [r0, #4]
	bl trans
	str r1, [r2, #GPIO_HEX1]
	
	ldr r11, [sp]
	add sp, sp, #4
	mov pc, r11		/* pop */ 

min0:
	sub sp, sp, #4
	str lr, [sp]	/* push */
	ldr r1, [r0, #8]	/* r1 = data[2] : min0 */
	add r1, r1, #1
	cmp r1, #10
	moveq r1, #0
	str r1, [r0, #8]
	bleq min1
	ldr r1, [r0, #8]
	bl trans
	str r1, [r2, #GPIO_HEX2]
	ldr r11, [sp]
	add sp, sp, #4
	mov pc, r11 	/* pop */
	
min1:
	sub sp, sp, #4
	str lr, [sp]	 	/* push */
	ldr r1, [r0, #0xC]	/* r1 = data[3] : min1 */
	add r1, r1, #1
	cmp r1, #6
	moveq r1, #0
	str r1, [r0, #0xC]
	bleq hour0
	ldr r1, [r0, #0xC]
	bl trans
	str r1, [r2, #GPIO_HEX3]
	
	ldr r11, [sp]
	add sp, sp, #4
	mov pc, r11			/* pop */

hour0:
	sub sp, sp, #4
	str lr, [sp]    	/* push */
	ldr r1, [r0, #0x10]	/* r1 = data[4] : hour0 */
	add r1, r1, #1
	cmp r1, #2
	str r1, [r0, #0x10]
	bleq hour2
	ldr r1, [r0, #0x10]
	cmp r1, #10
	moveq r1, #0
	str r1, [r0, #0x10]
	bleq hour1
	ldr r1, [r0, #0x10]
	bl trans
	str r1, [r2, #GPIO_HEX4]
	ldr r11, [sp]
	add sp, sp, #4
	mov pc, r11		/* pop */

hour2:
	sub sp, sp, #4
	str lr, [sp]
	ldr r1, [r0, #0x14]	/* r1 = data[5] : hour1 */
	cmp r1, #1
	moveq r1, #0
	streq r1, [r0, #0x14]
	streq r1, [r0, #0x10]
	moveq r1, #(SEG_0)
	streq r1, [r2, #GPIO_HEX4]
	streq r1, [r2, #GPIO_HEX5]
	bleq day
	
	ldr r11, [sp]
	add sp, sp, #4
	ldr pc, [sp]
	
hour1:
	sub sp, sp, #4
	str lr, [sp]    	/* push */
	ldr r1, [r0, #0x14]	/* r1 = data[5] : hour1 */
	add r1, r1, #1
	cmp r1, #2
	moveq r1, #0
	str r1, [r0, #0x14]
	bleq day
	ldr r1, [r0, #0x14]
	bl trans
	str r1, [r2, #GPIO_HEX5]
	
	ldr r11, [sp]
	add sp, sp, #4
	mov pc, r11 	/* pop */

day:  /* 0 : A, 1: P */
	sub sp, sp, #4
	str lr, [sp]
	ldr r1, [r0, #0x18] /* r1 = data[6] : day */
	cmp r1, #0
	moveq r1, #1
	movne r1, #0
	
	add r0, r0, #0x18
	str r1, [r0]
	moveq r1, #0xC /* P */
	movne r1, #(SEG_A) /* A */
	str r1, [r2, #GPIO_HEX7]

	ldr r11, [sp]
	add sp, sp, #4
	mov pc, r11 	/* pop */


trans:
	cmp r1, #0
	moveq r1, #(SEG_0)
	
	cmp r1, #1
	moveq r1, #(SEG_1)
	
	cmp r1, #2
	moveq r1, #(SEG_2)
	
	cmp r1, #3
	moveq r1, #(SEG_3)
	
	cmp r1, #4
	moveq r1, #(SEG_4)
	
	cmp r1, #5
	moveq r1, #(SEG_5)
	
	cmp r1, #6
	moveq r1, #(SEG_6)
	
	
	cmp r1, #7
	moveq r1, #(SEG_7)
	
	cmp r1, #8
	moveq r1, #(SEG_8)

	cmp r1, #9
	moveq r1, #(SEG_9)
	
	mov pc, r14	
	

softirq:


	movs    pc, r14

IRQ_handler:
	subs    pc, r14, #4

data:
		/* sec0, sec1, min0, min1, hour0, hour1, day */
	.word	0,    0,    0,    0,    0,     0,     0

/* No overflow  */
add64_op1:
   .word  0x22223333, 0x44445555
add64_op2:
   .word  0x33332222, 0x66665555
add64_res:
   .word  0x55555555, 0xAAAAAAAA
sub64_res:
   .word  0xEEEF1110, 0xDDDE0000



.align 4
irq_stack:
	.space 1024
sys_stack:
	.space 1024
usr_stack:
	.space 1024

