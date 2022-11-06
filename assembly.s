;@============================================================================
;@
;@ Student Name 1: Siddhesh Sawant
;@ Student 1 #: 301326234
;@ Student 1 userid (email): stu1 (ssawant@sfu.ca)
;@
;@ Student Name 2: student2
;@ Student 2 #: 123456782
;@ Student 2 userid (email): stu2 (stu2@sfu.ca)
;@
;@ Below, edit to list any people who helped you with the code in this file,
;@      or put ‘none’ if nobody helped (the two of) you.
;@
;@ Helpers: None
;@
;@ Also, reference resources beyond the course textbooks and the course pages on Canvas
;@ that you used in making your submission.
;@
;@ Resources:  _____None______
;@
;@% Instructions:
;@ * Put your name(s), student number(s), userid(s) in the above section.
;@ * Edit the "Helpers" line and "Resources" line.
;@ * Your group name should be "<userid1>_<userid2>" (eg. stu1_stu2)
;@ * Form groups as described at:  https://courses.cs.sfu.ca/docs/students
;@ * Submit your file to courses.cs.sfu.ca
;@
;@ Name        : assembly.s
;@ Description : bigAdd subroutine for Assignment.
;@ Copyright (C) 2021 Craig Scratchley    wcs (at) sfu (dot) ca  
;@============================================================================

;@ Tabs set for 8 characters in Edit > Configuration

#include "asm_include.h"
#include "73x_tim_l.h"
#include "73x_eic_l.h"

	IMPORT	printf
	
	PRESERVE8

	GLOBAL	FIQ_Init
	GLOBAL	FIQ_Handler
	GLOBAL	InitHwAssembly
	GLOBAL	LoopFnc
	AREA	||.text||, CODE, READONLY


	;@ *** modify the below lines for this assignment  ***
	;@ *** make pins of I/O port 0 strobe back and forth between
	;@     all the Bits in the range Bit 0 to Bit 15 ***
	;@  Turn on GPIO0 pin 0 

	

LoopFnc	
	B 	LoopFnc



InitHwAssembly
	;@  Setup GPIO6 - UART0 Tx pin setup (P6.9)     
	LDR 	R12, =GPIO6_BASE
	;@ GPIO_Mode_AF_PP
	LDRH	R1, [R12, #GPIO_PC0_OFS]
	ORR 	R1, R1, #GPIO_PIN_9
	STRH 	R1, [R12, #GPIO_PC0_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC1_OFS]
	ORR 	R1, R1, #GPIO_PIN_9
	STRH 	R1, [R12, #GPIO_PC1_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC2_OFS]
	ORR 	R1, R1, #GPIO_PIN_9
	STRH 	R1, [R12, #GPIO_PC2_OFS]

	;@ *** modify the below lines for this assignment  ***
	;@  Setup GPIO0 pin 0     
	
	;@ GPIO_Mode_OUT_PP
	
	;@ ^^^ modify the above lines ^^^
	MOV R2, #GPIO_PIN_0	
InitializeLoop 
	LDR 	R12, =GPIO0_BASE
	LDRH	R1, [R12, #GPIO_PC0_OFS]
	ADD 	R1, R1, R2
	STRH 	R1, [R12, #GPIO_PC0_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC1_OFS]
	BIC 	R1, R1, R2	;@ fill in an instruction to clear bit 0
	STRH 	R1, [R12, #GPIO_PC1_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC2_OFS]
	ORR 	R1, R1, R2
	STRH 	R1, [R12, #GPIO_PC2_OFS]
	
	mov 	R2, R2, LSL #1
	CMP	R2, #0x10000
	bne InitializeLoop
	;;;;;;;;;;;;;;;;;PIN8;;;;;;;;;;;;;;;

	LDR 	R12, =GPIO1_BASE
	
	LDRH	R1, [R12, #GPIO_PC0_OFS]
	ORR 	R1, R1, #GPIO_PIN_8
	STRH 	R1, [R12, #GPIO_PC0_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC1_OFS]
	BIC 	R1, R1, #GPIO_PIN_8
	STRH 	R1, [R12, #GPIO_PC1_OFS]
	
	LDRH 	R1, [R12, #GPIO_PC2_OFS]
	BIC 	R1, R1, #GPIO_PIN_8
	STRH 	R1, [R12, #GPIO_PC2_OFS]
	
	
	;;;;;;;;;;;;;TIMER, EIC AND CFG ;;;;;;;;;;;;;;;;;;
	
	LDR	R12, =TIM0_BASE
	LDR	R1, =0x8210;0x8011;0x8210
	STRH 	R1, [R12, #TIMn_CR1] ;OCMPA(WAVEFORM) = where OLVLB is 1 and olvla is 0
	
	LDR	R1, =0x0810;0xE000;0x0810 the last two digits are pre scale division factor
				; 40 = slow and 10 = fast, 8 is according to manual
				; ocbie = enable output compare b
	STRH 	R1, [R12, #TIMn_CR2]
	
	LDR	R12, =EIC_BASE
	LDR	R1, =0x00000003 ; fortunately to enable FIQ_en and FIE_FIR we need 0x00..02
	STRH 	R1, [R12, #EIC_FIR]
	STRH 	R1, [R12, #EIC_ICR]
	
	LDR	R12, =CFG_BASE  ; rising edge 
	MOV	R1, #1
	STRH 	R1, [R12, #CFG_EITE2]
	STRH 	R1, [R12, #CFG_EITE0]
	MOV	R1, #0
	STRH 	R1, [R12, #CFG_EITE1]
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	MOV	PC, LR

	
	// Below needed for HW7 and HW8
	// void* FIQ_Init (void* IRQ_Top);
	// make sure that FIQ_Init returns IRQ_Top in R0
	// FIQ_Init() will initialize R8 through R12 as desired,
	//     so is a non-conforming subroutine in this regard.
FIQ_Init
	// You can put your FIQ_Init here.
	MOV	PC, LR
	
	
FIQ_Handler
	// You can put your FIQ_Handler here.
	
	MOV	PC, LR


		
C_str   DCB  "C_string\n",0
	ALIGN	4

	END
