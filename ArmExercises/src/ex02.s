; Exemplo.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 12/03/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Ex02                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>

; -------------------------------------------------------------------------------
; Função main()
Ex02  
; Comece o código aqui <======================================================
	
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
    ALIGN                           ; garante que o fim da seção está alinhada 
    END                             ; fim do arquivo
