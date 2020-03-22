; ex04.s - ARITHMETICS
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

        EXPORT Ex04 
; -------------------------------------------------------------------------------

Ex04
; Start Here <======================================================
	
    ; a) Adicionar os números 101 e 253 atualizando os flags;
	mov R0, #101
    mov R1, #253
    adds R2, R0, R1
    ; R2 = 0x0162

    ; b) Adicionar os números 1500 e 40543 sem atualizar os flags;
    mov R0, #1500
    mov R1, #40543
    add R2, R0, R1 
    ; R2 = 0xA43B

    ; c) Subtrair o número 340 pelo número 123 atualizando os flags;
    mov R0, #340
    mov R1, #123
    subs R2, R0, R1
    ; R2 = 0x007B

    ; d) Subtrair o número 1000 pelo número 2000 atualizando os flags;
    mov R0, #1000
    mov R1, #2000
    subs R2, R0, R1
    ; R2 = 0xFFFFFC18 = -1000
    ; N = 1

    ; e) Multiplicar o número 54378 por 4; (Essa operação é semelhante a qual?)
    mov R0, #54378
    mov R1, #4
    mul R2, R0, R1
    ; R2 = 0x000351A8

    ; f) Multiplicar com o resultado em 64 bits os números 0x11223344 e 0x44332211
    mov   R0, #0x3344
    movt  R0, #0x1122
    mov   R1, #0x2211
    movt  R1, #0x4433
    umull R3, R4, R0, R1
    ; R3 = 0xF4A06F84
    ; R4 = 0x049081B5

    ; g) Dividir o número 0xFFFF7560 por 1000 com sinal;
    mov  R0, #0x7560
    movt R0, #0xFFFF
    mov  R1, #1000
    sdiv R2, R0, R1
    ; R2 = 0xFFFFFFDD

    ; h) Dividir o número 0xFFFF7560 por 1000 sem sinal;
    mov  R0, #0x7560
    movt R0, #0xFFFF
    mov  R1, #1000
	udiv R2, R0, R1
    ; R2 = 0x00418913

	nop 
    align
    end
