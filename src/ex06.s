; ex06.s - STACK
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

        EXPORT Ex06
; -------------------------------------------------------------------------------

Ex06
; Start Here <======================================================
	
    ; a) Mover o valor 10 para o registrador R0
    mov R0, #10

    ; b) Mover o valor 0xFF11CC22 para o registrador R1
    mov  R1, #0xCC22
    movt R1, #0xFF11

    ; c) Mover o valor 1234 para o registrador R2
    mov R2, #1234

    ; d) Mover o valor 0x300 para o registrador R3
    mov R3, #0x300

    ; e) Empurrar para a pilha o R0
    push {R0}

    ; f) Empurrar para a pilha os R1, R2 e R3
    push {R1}
    push {R2}
    push {R3}

    ; g) Visualizar a pilha na memória (o topo da pilha está em 0x2000.0400)

    ; h) Mover o valor 60 para o registrador R1
    mov R1, #60

    ; i) Mover o valor 0x1234 para o registrador R2
    mov R2, #0x1234

    ; j) Desempilhar corretamente os valores para os registradores R0, R1, R2 e R3
    pop {R3}
    pop {R2}
    pop {R1}
    pop {R0}

	nop 
    align
    end
