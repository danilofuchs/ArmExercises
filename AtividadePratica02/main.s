; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este programa deve esperar o usuário pressionar uma chave.
; Caso o usuário pressione uma chave, um LED deve piscar a cada 1 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Definições de Valores


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
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
		IMPORT  PLL_Init
		IMPORT  SysTick_Init
		IMPORT  SysTick_Wait1ms			
		IMPORT  GPIO_Init
        IMPORT  PortN_Output
        IMPORT  PortF_Output	
        IMPORT  PortJ_Input	


MODE_PASSEIO_CAVALEIROS EQU 0x0
MODE_BINARY_COUNTER EQU 0x1

; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	MOV R8, #MODE_PASSEIO_CAVALEIROS		; R8 = MODE_SELECT
	MOV R9, #1000		 					; R9 = SPEED (ms)
	MOV R10, #0		 					    ; R10 = PASSEIO CAVALEIROS ASCENDING?
	MOV R11, #2_1000		 				; R11 = STATE PASSEIO CAVALEIROS

MainLoop
; ****************************************
; Escrever código que lê o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************

	MOV R0, R11
	BL Display_LED
	BL Set_New_State
	BL Wait_ms
	; BL Read_Button

	B MainLoop

;--------------------------------------------------------------------------------
; Função Display_LED
; Parâmetro de entrada: R0: 4-bit data to be displayed
; Parâmetro de saída: Não tem
Display_LED
	PUSH {LR}

	; R0[3] => PN1
	; R0[2] => PN0
	; R0[1] => PF4
	; R0[0] => PF0

	MOV R1, #2_00001100 ; MASK -> Get 3, 2
	AND R1, R1, R0 ; Get info from first 2 bits
	LSR R1, R1, #2 ; Shift these two bits from 3, 2 -> 1, 0

	PUSH {R0}		; Avoid overriding input
	MOV R0, R1 		; Display result in port N via R0
	BL PortN_Output
	POP {R0}

	MOV R2, #2_00000000

	MOV R1, #2_00000010 	; MASK -> Get bit 1
	AND R1, R1, R0 			; Get info from bit 1
	CMP R1, #2_00000010
	IT EQ
		ORREQ R2, #2_00010000 ; Set PF4
	
	MOV R1, #2_00000001 	; MASK -> Get bit 0
	AND R1, R1, R0 			; Get info from bit 0
	ORR R2, R1, R2			; Set PF0 = R0[0]

	PUSH {R0} 		; Avoid overriding input
	MOV R0, R2 		; Display result in port F via R0
	BL PortF_Output
	POP {R0}

	POP {LR}
	BX LR

Set_New_State
	PUSH {LR}

	MOV R0, #MODE_PASSEIO_CAVALEIROS
	CMP R8, R0
	BLEQ Cavaleiros
	
	POP {LR}
	BX LR

Cavaleiros
	PUSH {LR}

	CMP R10, #1
	BLEQ Cavaleiros_Ascending
	BLNE Cavaleiros_Descending

	POP {LR}
	BX LR

Cavaleiros_Ascending
	CMP R11, #2_0001
	ITT EQ
		MOVEQ R11, #2_0010
		BXEQ LR
		
	CMP R11, #2_0010
	IT EQ
		MOVEQ R11, #2_0100
		BXEQ LR
	
	CMP R11, #2_0100
	ITTT EQ
		MOVEQ R11, #2_1000
		MOVEQ R10, #0 ; End of iteration, change to descending
		BXEQ LR
	
	BX LR

Cavaleiros_Descending
	CMP R11, #2_1000
	ITT EQ
		MOVEQ R11, #2_0100
		BXEQ LR

	CMP R11, #2_0100
	ITT EQ
		MOVEQ R11, #2_0010
		BXEQ LR

	CMP R11, #2_0010
	ITTT EQ
		MOVEQ R11, #2_0001
		MOVEQ R10, #1 ; End of iteration, change to ascending
		BXEQ LR
	
	BX LR

Wait_ms
	PUSH {LR}

	MOV R0, R9 ; Wait for SPEED
	BL SysTick_Wait1ms

	POP {LR}
	BX LR

; Reads button.
; Returns R0 -> #1 if button is pressed
Read_Button
	PUSH {LR}

	BL PortJ_Input
	MOV R1, #2_00000001 ; MASK -> Only compare value of bit 0
	AND R1, R0, R1 		; R1 = R0 AND R1
	CMP R1, #2_00000000 ; R1 should be #0 if button is pressed
	ITE EQ
		MOVEQ R0, #1 ; Pressed
		MOVNE R0, #0 ; Not Pressed

	POP {LR}
	BX LR

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
