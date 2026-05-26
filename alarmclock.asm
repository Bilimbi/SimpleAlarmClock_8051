;         __________
;        /_________/`-_
;     _-'   ____   `-_ /|
;    { >=+-<8051>-+=< } |
;    |  ____________  | |
;    | |    \/||    | | |
;    | |    /\||    | | |
;    | |            | | |
;    | ||\/      |||| | |
;    | ||/\ ,*.  |||| | |
;    | |  ,'   `.   | | |
;    | |    \ /| `. | | |
;    | |_____V_|____| | |
;    | |    : /     | | |
;    | |    :/:     | | |
;    | |    / :     | | |
;    | |   /: @     | | |
;    | |  / :       | | |
;    | |( ) :       | | |   
;    | |    :       | | |
;    | |    :       | | |
;    | |    @       | | |
;    | |____________| | |  
;    |______/VV\_______|/

;------------ Setup Timers ------------
;TIMER 0
T0_G	EQU	0	;GATE
T0_C	EQU	0	;COUNTER/-TIMER
T0_M	EQU	1	;MODE (0..3)
TIM0	EQU	T0_M+T0_C*4+T0_G*8
;TIMER 1
T1_G	EQU	0	;GATE
T1_C	EQU	0	;COUNTER/-TIMER
T1_M	EQU	0	;MODE (0..3)
TIM1	EQU	T1_M+T1_C*4+T1_G*8

TMOD_SET	EQU	TIM0+TIM1*16

;50[ms] = 50 000[uS]*(11.0592[MHz]/12) =
;	= 46 080 cycles = 180 * 256
TH0_SET		EQU	256-180
TL0_SET		EQU	0
;---------------------------------------

LED	EQU	P1.7 ; Define LED pin

; Define alarm time storage in the RAM
ALM_H EQU 33H ; Hour of the alarm
ALM_M EQU 34H ; Minute of the alarm
ALM_C EQU 35H ; Counter for alarm duration in seconds

    LJMP START
    ORG 100H ; Jump to the start of the program
START:
    LCALL LCD_INIT

    MOV TMOD, #TMOD_SET ; Timer 0 is counting
    MOV TH0, #TH0_SET ; Set timer 0 to 50ms
    MOV TL0, #TL0_SET
    SETB TR0 ; Start timer 0

    ; Setup current time
    LCALL SET_CURRENT_TIME

    ; Setup alarm time
    LCALL SET_ALARM_TIME

    MOV ALM_C, #0 ; Reset alarm counter
    SETB LED ; Turn off the LED

MAIN_LOOP:
    ; Display the current time on the LCD
    LCALL DISPLAY_TIME

    ; Check if the alarm time has been reached
    LCALL CHECK_ALARM

    ; One second delay
    LCALL DELAY_1S
    
    ; One second increase of the current time
    LCALL INC_TIME

    SJMP MAIN_LOOP

SET_CURRENT_TIME:
    LCALL LCD_CLR
    ; HOUR
    LCALL WAIT_KEY ; Get XO
    MOV B, #10
    MUL AB
    MOV R1,A
    
    LCALL WAIT_KEY ; Get OX
    ADD A,R1

    MOV R7,A
    LCALL PRINT_DEC
    
    ; MIN
    LCALL WAIT_KEY ; Get XO
    MOV B, #10
    MUL AB
    MOV R1,A
    
    LCALL WAIT_KEY ; Get OX
    ADD A,R1

    MOV R6,A
    LCALL PRINT_DEC

    ; SEX
    LCALL WAIT_KEY ; Get XO
    MOV B, #10
    MUL AB
    MOV R1,A
    
    LCALL WAIT_KEY ; Get OX
    ADD A,R1

    MOV R5,A
    LCALL PRINT_DEC
    RET ; Return from subroutine

SET_ALARM_TIME:
    LCALL LCD_CLR

    ; HOUR alarm
    LCALL WAIT_KEY
    MOV B, #10
    MUL AB
    MOV R1,A
    LCALL WAIT_KEY
    ADD A,R1
    MOV ALM_H, A      ; Write to RAM
    LCALL PRINT_DEC
    
    ; MIN alarm
    LCALL WAIT_KEY
    MOV B, #10
    MUL AB
    MOV R1,A
    LCALL WAIT_KEY
    ADD A,R1
    MOV ALM_M, A      ; Write to RAM
    LCALL PRINT_DEC
    RET

DISPLAY_TIME:
    LCALL LCD_CLR
    MOV A, R7
    LCALL PRINT_DEC ; Print hours
    
    MOV A, #':'
    LCALL WRITE_DATA
    
    MOV A, R6
    LCALL PRINT_DEC ; Print minutes
    
    MOV A, #':'
    LCALL WRITE_DATA
    
    MOV A, R5
    LCALL PRINT_DEC ; Print seconds
    RET

PRINT_DEC:
    MOV B, #10
    DIV AB
    ADD A, #'0'
    LCALL WRITE_DATA
    MOV A, B
    ADD A, #'0'
    LCALL WRITE_DATA
    RET

CHECK_ALARM:
    ; Check seconds
    MOV A, R5
    JNZ ALARM_STATE_UPDATE 

    ; Check minutes
    MOV A, R6
    CJNE A, ALM_M, ALARM_STATE_UPDATE

    ; Check hours
    MOV A, R7
    CJNE A, ALM_H, ALARM_STATE_UPDATE

    ; Set alarm counter to 2 seconds when the alarm time is reached
    MOV ALM_C, #2 

ALARM_STATE_UPDATE:
    MOV A, ALM_C
    JZ TURN_OFF_LED
    CLR LED ; Turn on the LED
    RET

TURN_OFF_LED:
    SETB LED ; Turn off the LED
    RET

DELAY_1S:
    MOV R2, #20 ; 20 * 50ms = 1 second

DELAY_LOOP:
    JNB TF0, $ ; Wait for timer 0 overflow flag
    CLR TF0 ; Clear the flag
    MOV TH0, #TH0_SET
    MOV TL0, #TL0_SET
    DJNZ R2, DELAY_LOOP

    ; Decrease the alarm counter by 1 second
    MOV A, ALM_C
    JZ SKIP_ALM_DEC
    DEC ALM_C

SKIP_ALM_DEC:
    RET

INC_TIME:
    INC R5            ; Increase seconds
    CJNE R5, #60, INC_END
    MOV R5, #0        ; Reset seconds
    
    INC R6            ; Increase minutes
    CJNE R6, #60, INC_END
    MOV R6, #0        ; Reset minutes
    
    INC R7            ; Increase hours
    CJNE R7, #24, INC_END
    MOV R7, #0        ; Reset hours

INC_END:
    RET

STOP:
    SJMP $
    NOP