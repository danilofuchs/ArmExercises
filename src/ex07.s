; ex07.s - BRANCHES
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

        EXPORT Ex07
; ------------------------------------------------------------------------------

Ex07
; Start Here <======================================================
	
    ; a) Mover para o R0 o valor 10
    mov R0, #10

    ; b) Somar R0 com 5 e colocar o resultado em R0
    add R0, #5

    ; c) Enquanto a resposta não for 50 somar mais 5
    bl add5until50
    
    ; d) Quando a resposta for 50 chamar uma função que:
    ;   d.1) Copia o R0 para R1
    ;   d.2) Verifica se R1 é menor que 50
    ;   d.3) Se for menor que 50 incrementa, caso contrário modifica para -50
    bl func2

    nop

endProgram 
    b endProgram

add5until50
    ; while (R0 < 50) { R0 = R0 + 5 }
    cmp R0, #50
    bxeq  LR        ; Is 50? Return to initial caller
    add R0, #5      ; Not 50, should add 5
    b   add5until50 ; Call itselt, not altering LR

func2
    ;   d.1) Copia o R0 para R1
    ;   d.2) Verifica se R1 é menor que 50
    ;   d.3) Se for menor que 50 incrementa, caso contrário modifica para -50
    mov R1, R0
    cmp R1, #50
    ite     lo
        addlo R1, #1
        movhs R1, #-50
    bx LR

    align
    end
