.global lab1
.syntax unified

#define A #5
#define B #7
#define C #3

// ((a & b) >> 1) + c!

lab1:
	push {lr}
	mov r0, A
	and r0, B
	lsr r1, r0, #1
	mov r0, #1
	
	mov r2, C
	bl factorial
	add r0, r1 
	pop {pc}

factorial:
	push { lr }
	.fact_calc:
		mul r0, r2
		subs r2, #1
		bne .fact_calc
	pop { pc }