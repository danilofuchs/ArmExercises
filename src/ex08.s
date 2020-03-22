; ex08.s - FACTORIAL
; Developed for board EK-TM4C1294XL
; Danilo Fuchs
; 22/03/2020

; Template:
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB
; -------------------------------------------------------------------------------

; -------------------------------------------------------------------------------

		AREA  DATA, ALIGN=2


; -------------------------------------------------------------------------------

        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT Ex08
; ------------------------------------------------------------------------------
fatorial
    ; R3 = Number to multiply by the accumulator
    mov R3, R2
    ; R0 = accumulator and result
    mov R0, #1
    push {LR}
    bl fatorialStep
    pop {LR}
    bx LR

fatorialStep
    ; R3 = Number to multiply by the accumulator
    ; R0 = accumulator and result
    cmp R3, #1
    ittt      hi
        ; if(R3 > 1) {
        ;   R0 = R0 * R3;
        ;   R3 = R3 - 1;
        ;   fatorial();
        ; }
        mulhi R0, R3
        subhi R3, #1
        bhi fatorialStep
    bx LR

Ex08
; Start Here <======================================================
	
    ; Ler de uma posição da memória RAM um número e calcular o
    ; fatorial. Armazenar o resultado em R0.

    ; Set R1 to address #0x2000.0000
    mov  R10, #0x0000
    movt R10, #0x2000

    ; (optional): Set data in RAM address:
    mov R1, #12
    str R1, [R10]

    ; Load RAM data to R2 
    ldr R2, [R10]

    bl fatorial
    
    nop
    align
    end
