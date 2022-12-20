## EECE.3170: Microprocessors I

// Including xc.h allows use of SFR names, bit masks, etc.
#include <xc.h>
    
    // Start of text section         
    .text		## Text section contains code
    .set noreorder	## Disable instruction reordering
    .globl main		## Define main label as a global entity
    .ent main		##   and an entry point    
    
main:
    // Configure Port B to power LED segments
    sw zero, TRISB	// Sets Port B bits = output
    li t0, _PORTB_RB3_MASK
    sw t0, TRISBSET	// ^Except for potentiometer (RB3) = input
    
    not t0, zero	// t0 = all 1s
    sw t0, ANSELB	// All port B bits = analog (both LED pins and pot. are analog)
    
    // Configure ADC with potentiometer input
    sw	    zero, AD1CON1	    ## Will use 10-bit conversion mode; 
				    ##    clear all other bits as well
    sw	    zero, AD1CON2	    ## Clear all bits (key bits: VCFG for Vdd/Vss as reference
				    ##    SMPI for 1 sample/interrupt)
    li	    s0, _AD1CON3_ADCS_MASK  ## ADCS = 0xFF --> T_AD = 510 * T_SRC (slowest possible A/D conversion clock)
    ori	    s0, s0, 0x1000	    ## SAMC = 0b10000 --> auto-sample time = 16 * T_AD
    sw	    s0, AD1CON3
    li	    s0, 11		    ## Potentiometer is connected to AN11
    sw	    s0, AD1CHS		    ##   so set AD1CHS = 11
    
    li	    s0, _AD1CON1_ON_MASK
    sw	    s0, AD1CON1SET	    ## Enable ADC

    li	    s1, _AD1CON1_SAMP_MASK  ## Will use s1 to control sampling
    li	    s2, _AD1CON1_DONE_MASK  ## Will use s2 to check if conversion done
    
    // Bit Masks in LATB for each digit:
    li s0, _PORTB_RB6_MASK	// A segment (works)
    sw s0, ODCBSET
    li s1, _PORTB_RB2_MASK	// B segment (works)
    sw s1, ODCBSET
    li s2, _PORTB_RB7_MASK	// C segment (works)
    sw s2, ODCBSET
    li s3, _PORTB_RB0_MASK	// D segment (works)
    sw s3, ODCBSET
    li s4, _PORTB_RB1_MASK	// E segment (works)
    sw s4, ODCBSET
    li s5, _PORTB_RB14_MASK	// F segment (works)
    sw s5, ODCBSET
    li s6, _PORTB_RB15_MASK	// G segment (works)
    sw s6, ODCBSET
    

    or s7, s1, s2		// All 7 segments
    or s7, s7, s3
    or s7, s7, s4
    or s7, s7, s5
    or s7, s7, s6
    or s7, s7, s0

    
    // Pull up network: 0=lit, 1=not lit
    // 0 = ABCDEF = NOT G
    or t0, zero, s6		// t0 = 0 DIGIT
    
    // 1 = BC = NOT ADEFG
    or t1, s0, s3
    or t1, t1, s4
    or t1, t1, s5
    or t1, t1, s6		// t1 = 1 DIGIT
    
    // 2 = ABDEG = NOT CF
    or t2, s2, s5		// t2 = 2 DIGIT
    
    // 3 = ABCDG = NOT EF
    or t3, s4, s5		// t3 = 3 DIGIT
    
    // 4 = BCFG = NOT ADE
    or t4, s0, s3
    or t4, t4, s4		// t4 = 4 DIGIT
    
    // 5 = ACDFG = NOT BE
    or t5, s1, s4		// t5 = 5 DIGIT
    
    // 6 = ACDEFG = NOT B
    or t6, zero, s1		// t6 = 6 DIGIT
    
    // 7 = ABC = NOT DEFG
    or t7, s3, s4
    or t7, t7, s5
    or t7, t7, s6		// t7 = 7 DIGIT
    
    // 8 = ABCDEFG (all segments)
    or t8, zero, zero		// t8 = 8 DIGIT
    
    // 9 = ABCDFG = NOT E
    or t9, zero, s4		// t9 = 9 DIGIT
    
    
    
    // After setup - still need s7 (to clear segments) and t0-t9 (for each digit)
    // Need to reset s1,s2
    li	    s1, _AD1CON1_SAMP_MASK  ## Will use s1 to control sampling
    li	    s2, _AD1CON1_DONE_MASK  ## Will use s2 to check if conversion done
    
mainloop:
    sw	    s1, AD1CON1SET	    ## Set SAMP = 1 --> start sampling
    
    // Delay loop to wait ~3000 cycles until starting conversion
    jal	    delay
    nop
    
    sw	    s1, AD1CON1CLR	    ## Set SAMP = 0 --> start converting
    
    // Delay loop to wait ~3000 cycles until even bothering to check DONE bit
    jal	    delay
    nop
    
    // Repeatedly check DONE bit to figure out if conversion is complete
chkdone:
    lw	    s3, AD1CON1
    and	    s3, s3, s2		    ## Isolate DONE bit (s2 = "DONE" mask)
    beq	    s3, zero, chkdone	    ## Keep polling DONE if it's not set
    nop
    
    /* 
     If you reach this point, conversion is done
       Use upper 5 bits of result to determine which LEDs to turn on
    */
    lw	    s6, ADC1BUF0	    ## Read result into a0
    
    
    jal	    setNum		    ## Call function below
    nop
    
    j	    mainloop
    nop
    
    .end main
    
     .globl delay
    .ent delay
delay:
    li	    s5, 1000
delay1:
    addi    s5, s5, -1
    bne	    s5, zero, delay1
    nop
    
    jr	    ra
    nop
    .end delay
    
    .globl setNum
    .ent setNum
setNum:
    // If number is 0-95, set number to 0 and jump to end of fn.
    slti s4, s6, 96
    beq s4, zero, over0
    nop
    sw s7, LATBCLR
    sw t0, LATBSET
    j setDone
    nop

  over0:  
    // If number is 96-198, set number to 1 and jump to end of fn.
    slti s4, s6, 199
    beq s4, zero, over1
    nop
    sw s7, LATBCLR
    sw t1, LATBSET
    j setDone
    nop

  over1:
    // If number is 199-301, set number to 2 and jump to end of fn
    slti s4, s6, 302
    beq s4, zero, over2
    nop
    sw s7, LATBCLR
    sw t2, LATBSET
    j setDone
    nop

   over2: 
    // If number is 302-404, set number to 3 and jump to end of fn.
    slti s4, s6, 404
    beq s4, zero, over3
    nop
    sw s7, LATBCLR
    sw t3, LATBSET
    j setDone
    nop

    over3:
    // If number is 405-507, set number to 4 and jump to end of fn.
    slti s4, s6, 508
    beq s4, zero, over4
    nop
    sw s7, LATBCLR
    sw t4, LATBSET
    j setDone
    nop

    over4:
    // If number is 508-610, set number to 5 and jump to end of fn.
    slti s4, s6, 611
    beq s4, zero, over5
    nop
    sw s7, LATBCLR
    sw t5, LATBSET
    j setDone
    nop

    over5:
    // If number is 611-713, set number to 6 and jump to end of fn.
    slti s4, s6, 714
    beq s4, zero, over6
    nop
    sw s7, LATBCLR
    sw t6, LATBSET
    j setDone
    nop

    over6:
    // If number is 714-817, set number to 7 and jump to end of fn.
    slti s4, s6, 817
    beq s4, zero, over7
    nop
    sw s7, LATBCLR
    sw t7, LATBSET
    j setDone
    nop

    over7:
    // If number is 818-920, set number to 8 and jump to end of fn.
    slti s4, s6, 921
    beq s4, zero, over8
    nop
    sw s7, LATBCLR
    sw t8, LATBSET
    j setDone
    nop

    over8:
    // If number is 921-1023, set number to 9 and jump to end of fn.
    sw s7, LATBCLR
    sw t9, LATBSET
    
setDone:
    jr ra
    nop
    
    .end setNum
    
// For debugging
    .globl delay2
    .ent delay2
delay2:
    li	    s5, 2000000
delay12:
    addi    s5, s5, -1
    bne	    s5, zero, delay12
    nop
    
    jr	    ra
    nop
    .end delay2
