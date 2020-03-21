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
        EXPORT Ex02                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>

; -------------------------------------------------------------------------------
; Fun��o main()
Ex02  
; Comece o c�digo aqui <======================================================
	
	MOV   R8,#0xF0
	MOV   R9,#2_01010101
	ANDS  R0,R8,R9
	
	MOV  R8,#2_11001100
	MOV  R9,#2_00110011
	ANDS R1,R8,R9
	
	MOV  R8,#2_10000000
	MOV  R9,#2_00110111
	ORRS   R2,R8,R9
	
	MOV  R8,#0xABCD
	MOVT R8,#0xABCD
	MOV  R9,#0xFFFF
	BICS R3,R8,R9
	
	
	NOP 
    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo
