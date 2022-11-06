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
;@ Helpers: Namsakhi Kumar
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


	SUB     LR, LR, #4              ; Update Link Register
        STMFD   SP!, {R0-R7, LR}        ; Save Workspace & LR to Stack
        MRS     R0, SPSR                ; Copy SPSR to R0
        STMFD   SP!, {R0}               ; Save SPSR to Stack (8-byte)
	
        BL      FIQ_Handler            ; Branch to FIQ Handler
	//include FIQ2.s
	
        LDMFD   SP!, {R0}               ; Restore SPSR to R0
        MSR     SPSR_cxsf, R0           ; Restore SPSR
        LDMFD   SP!, {R0-R7, PC}^       ; Return to program after
                                        ; Data Abort Instruction
StorbeLeft
	LDRH	R10, [R12, #GPIO_PD_OFS]
	CMP	R10, #0
	MOVEQ	R10, #0x0001
	LSLNE	R10, #1
	STRH	R10, [R12, #GPIO_PD_OFS]
	CMP	R10, #0x8000
	MOVEQ	R8, #1
	MOV	PC, LR
		
	
StorbeRight
	LDRH	R10, [R12, #GPIO_PD_OFS]
	CMP	R10, #0x0001
	MOVEQ	R8, #0
	LSRNE	R10, #1
	STRH	R10, [R12, #GPIO_PD_OFS]
	MOV	PC, LR
					
FIQ_Handler
	// You can put your FIQ_Handler here.
	// At that point, you can remove some code from LoopFnc above at top.
	LDR	R12, =EIC_BASE
	LDRH 	R11, [R12, #EIC_FIPR]
	CMP	R11, #2
	BEQ	TIM0_INTERRUPT
	CMP	R11, #3
	BEQ	EXTERNAL_INTERRUPT
	CMP	R11, #1
	BEQ	EXTERNAL_INTERRUPT
	MOV	PC, LR

TIM0_INTERRUPT
	LDR	R12, =TIM0_BASE
	LDRH 	R10, [R12, #TIMn_SR]
	BIC	R10,R10,#0x00000800
	STRH 	R10, [R12, #TIMn_SR] ; OCFB generates a interrupt so clear it
	
	LDR	R12, =EIC_BASE
	LDRH 	R10, [R12, #EIC_FIPR ]
	STRH 	R10, [R12, #EIC_FIPR ] ;clear the pending bits

	LDR 	R12, =GPIO0_BASE
	CMP 	R8, #0		; Stores the direction of led's
	BEQ StorbeLeft
	BNE StorbeRight

	
EXTERNAL_INTERRUPT
	LDR	R12, =TIM0_BASE
	LDRB 	R10, [R12, #TIMn_CR2]
	LSL	R10, #1
	CMP	R10, #0x100
	BHS	jump_here 	; avoid overflow
	STRB 	R10, [R12, #TIMn_CR2]
jump_here
	LDR	R12, =EIC_BASE
	LDRH 	R1, [R12, #EIC_FIPR ]
	STRH 	R1, [R12, #EIC_FIPR ]
	
	LDR 	R12, =GPIO0_BASE
	CMP 	R8, #0
	BEQ StorbeLeft
	BNE StorbeRight
	MOV	PC, LR	

	
