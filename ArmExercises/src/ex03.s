; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; �rea de Dados - Declara��es de vari�veis
		AREA  DATA, ALIGN=2
		; Se alguma vari�vel for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a vari�vel <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma vari�vel de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posi��o da RAM		

; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT Ex03                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; -------------------------------------------------------------------------------
; Fun��o main()
Ex03  
; Comece o c�digo aqui <======================================================
	
	MOV R1,#701
	LSRS R1,R1,#5
	
	MOV R2,#32067
	NEG R2,R2
	LSRS R2,R2,#4
	
	MOV R3,#701
	ASRS R3,R3,#5
	
	MOV R4,#32067
	NEG R4,R4
	ASRS R4,R4,#4
	
	MOV R5,#255
	LSLS R5,R5,#8
	
	MOV R6,#58982
	NEG R6,R6
	LSLS R6,R6,#18
	
	MOV R7,#0x1234
	MOVT R7,#0xFABC
	ROR R7,R7,#10
	
	MOV R8,#0x4321
	
	NOP 
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
