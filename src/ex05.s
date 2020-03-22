; ex05.s - IF-THEN
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

        EXPORT Ex05
; -------------------------------------------------------------------------------

Ex05
; Start Here <======================================================
	
    ; a) Mova o valor 10 para o registrador R0
    mov R0, #10

    ; b) Teste se o registrador é maior ou igual que 9
    cmp R0, #9

    ; c) Crie um bloco com If-Then com 3 execuções condicionais
    ;       - Se sim, salve o número 50 no R1
    ;       - Se sim, adicione 32 com o R1 e salve o resultado em R2
    ;       - Se não, salve o número 75 no R3

    itte      hs            ; Higher or same
        movhs R1, #50       ; then
        addhs R2, R1, #32   ; then
        movlo R3, #75       ; else

    ; d) Agora verifique se o registrador é maior ou igual a 11 e execute novamente o passo (c)
    cmp R0, #11
    itte      hs            ; Higher or same
        movhs R1, #50       ; then
        addhs R2, R1, #32   ; then
        movlo R3, #75       ; else

	nop 
    align
    end
