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
    //FIX - RB3 = potentiometer = input
    sw zero, TRISB	// All Port B bits = output
    not t0, zero	// t0 = all 1s
    sw t0, ANSELB	// All port B bits = analog
    
    
    /* TEST STUFF
    //TEST
    sw	    zero, TRISA		    ## TRISA = 0  --> all PORTA bits = output
    sw	    zero, ANSELA	    ## ANSELA = 0 --> all PORTA bits digital
    li	    t9, _PORTA_RA0_MASK	    ## $s1 = 0x00000001 (control LED1)
    //li t1, _PORTB_RB0_MASK	// t1 = bit mask for RB0
    // li t1, _PORTB_CNPUB_MASK	// mask for port b pull up
    // li t2, _PORTB_CNPDB_MASK	// mask for port b pull down
    sw t1, ODCBSET
    //sw t0, CNPUBSET	// enable port b pull up
    //sw t0, CNPDBSET	// disable port b pull down
    
    //sw t1, LATBCLR // - turn LED ON

    
    sw t1, LATBSET // - turn LED OFF
    sw t9, LATACLR // FIX - FOR DEBUGGING (LED1 OFF)
    jal delay
    nop
    
    sw t1, LATBCLR
    sw t9, LATAINV // FIX - FOR DEBUGGING
    jal delay
    nop
    
    sw t1, LATBSET
    sw t9, LATAINV // FIX - FOR DEBUGGING
    jal delay
    nop
    
    sw t1, LATBCLR
    sw t9, LATAINV // FIX - FOR DEBUGGING
    jal delay
    nop
    
    sw t1, LATBSET
    sw t9, LATAINV // FIX - FOR DEBUGGING
    jal delay
    nop
    
    sw t1, LATBCLR
    sw t9, LATAINV
    */
    sw t0, LATBCLR
    
    // Bit Masks in LATB for each digit:
    li s0, _PORTB_RB6_MASK	// A segment (was b9)
    sw s0, ODCBSET
    li s1, _PORTB_RB2_MASK	// B segment (works)
    sw s1, ODCBSET
    li s2, _PORTB_RB11_MASK	// C segment (was b11)
    sw s2, ODCBSET
    li s3, _PORTB_RB0_MASK	// D segment (works)
    sw s3, ODCBSET
    li s4, _PORTB_RB1_MASK	// E segment (works)
    sw s4, ODCBSET
    li s5, _PORTB_RB14_MASK	// F segment (works)
    sw s5, ODCBSET
    li s6, _PORTB_RB15_MASK	// G segment (works)
    sw s6, ODCBSET
    
    /*
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
     */
     
    
    not s7, zero
    sw s7, LATBSET
    sw s0, LATBCLR
    jal delay
    nop
  
    sw s7, LATBSET
    sw s1, LATBCLR
    jal delay
    nop
    
    sw s7, LATBSET
    sw s2, LATBCLR
    jal delay
    nop
    
    sw s7, LATBSET
    sw s3, LATBCLR
    jal delay
    nop
    
    sw s7, LATBSET
    sw s4, LATBCLR
    jal delay
    nop
    
    sw s7, LATBSET
    sw s5, LATBCLR
    jal delay
    nop
    
    sw s7, LATBSET
    sw s6, LATBCLR
    jal delay
    nop
    
    
    /*
    sw t0, LATBCLR
    jal delay
    nop
    
    
    sw s0, LATBCLR
    sw t1, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t2, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t3, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t4, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t5, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t6, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t7, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t8, LATBSET
    jal delay
    nop
    
    sw s0, LATBCLR
    sw t9, LATBSET
    jal delay
    nop
    */
    
mainloop:
    
    j	    mainloop
    nop
    
    .end main
    
     .global delay
    .ent delay
delay:
    // DEBUG
    li	    t0, 2000000
delay1:
    addi    t0, t0, -1
    bne	    t0, zero, delay1
    nop
    
    jr	    ra
    nop
    .end delay
