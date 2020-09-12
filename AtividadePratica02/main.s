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
	MOV R9, #1000		 					; R9 = DELAY (ms)
	MOV R10, #0		 					    ; R10 = PASSEIO CAVALEIROS ASCENDING?
	MOV R11, #2_1000		 				; R11 = STATE PASSEIO CAVALEIROS
	MOV R12, #2_0000		 				; R12 = STATE BINARY COUNTER

MainLoop
; ****************************************
; Escrever código que lê o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************
	BL Get_Current_State
	BL Display_LED
	BL Wait_Delay
	BL Set_New_State
	BL Read_Buttons
	BL Detect_Mode_Change
	BL Detect_Delay_Change

	B MainLoop

; Output: R0 -> 4-bit data to be displayed
Get_Current_State
	MOV R0, #MODE_PASSEIO_CAVALEIROS
	CMP R8, R0
	ITE EQ
		MOVEQ R0, R11
		MOVNE R0, R12
	
	BX LR

; Displays 4-bit input in 4 onboard LEDs
; Input: R0: 4-bit data to be displayed
Display_LED
	PUSH {LR}

	; R0[3] => PN1
	; R0[2] => PN0
	; R0[1] => PF4
	; R0[0] => PF0

	; ==== FIRST TWO LEDs (PN1, PN0) ====

	MOV R1, #2_00001100 ; MASK -> Get 3, 2
	AND R1, R1, R0 ; Get info from first 2 bits
	LSR R1, R1, #2 ; Shift these two bits from 3, 2 -> 1, 0

	PUSH {R0}		; Avoid overriding input
	MOV R0, R1 		; Display result in port N via R0
	BL PortN_Output
	POP {R0}

	
	; ==== LAST TWO LEDs (PF4, PF0) ====

	MOV R2, #2_00000000 	; Ouput for pin F

	MOV R1, #2_00000010 	; MASK -> Get bit 1
	AND R1, R1, R0 			; Get info from bit 1
	CMP R1, #2_00000010
	IT EQ
		ORREQ R2, #2_00010000 ; Set PF4
	
	MOV R1, #2_00000001 	; MASK -> Get bit 0
	AND R1, R1, R0 			; Get info from bit 0
	ORR R2, R1, R2			; Set PF0 = R0[0]

	PUSH {R0} 		; Avoid overriding input (redundant)
	MOV R0, R2 		; Display result in port F via R0
	BL PortF_Output
	POP {R0}

	POP {LR}
	BX LR

; Calculates the new desired state
Set_New_State
	PUSH {LR}

	MOV R0, #MODE_PASSEIO_CAVALEIROS
	CMP R8, R0
	BLEQ Cavaleiros_Next_State

	MOV R0, #MODE_BINARY_COUNTER ; Compare again since flags may have changed
	CMP R8, R0
	BLEQ BinaryCounter_Next_State
	
	POP {LR}
	BX LR

; Calculates the new desired state for the "Cavaleiros" mode
Cavaleiros_Next_State
	PUSH {LR}

	PUSH {R10}
	CMP R10, #1
	BLEQ Cavaleiros_Ascending
	POP {R0} ; Recover R10 from before the jump
	CMP R0, #0 ; Compare again because flags may have been reset
	BLEQ Cavaleiros_Descending

	POP {LR}
	BX LR

; Calculates the new desired state for the "Cavaleiros" mode, ascending
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

; Calculates the new desired state for the "Cavaleiros" mode, descending
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

; Calculates the new desired state for the "Binary Counter" mode
; Output: R12 -> new state
BinaryCounter_Next_State
	CMP R12, #15
	ITE EQ
		MOVEQ R12, #0 		; if R12 == 15, R12 = 0
		ADDNE R12, R12, #1	; else, R12 = R12 + 1
	
	BX LR

; Waits for DELAY (R9)
Wait_Delay
	PUSH {LR}

	MOV R0, R9 ; Wait for DELAY
	BL SysTick_Wait1ms

	POP {LR}
	BX LR

; Reads buttons.
; Returns R0 -> 2_00000011 if both buttons are pressed
Read_Buttons
	PUSH {LR}

	BL PortJ_Input
	MOV R1, #2_00000011 ; MASK -> Only get values of bits 0 and 1
	BIC R0, R1, R0		; R0 = R1 AND (NOT R0) -> Gets only correct values

	POP {LR}
	BX LR

; Input: R0 -> 2_00000010 if delay-change button is pressed
Detect_Delay_Change
	PUSH {LR}

	MOV R1, #2_00000010 ; MASK -> Only get value of bit 0
	AND R1, R1, R0
	CMP R1, #2_00000010
	BLEQ Change_Delay

	POP {LR}
	BX LR

; Output: R9 (delay) decremented or reset to default value
Change_Delay
	PUSH {LR}
	BL Debounce_Buttons
	POP {LR}

	CMP R9, #250
	ITT	EQ
		MOVEQ R9, #1000
		BXEQ LR

	CMP R9, #500
	ITT	EQ
		MOVEQ R9, #250
		BXEQ LR

	CMP R9, #1000
	ITT	EQ
		MOVEQ R9, #500
		BXEQ LR

	BX LR

; Input: R0 -> 2_00000001 if mode-change button is pressed
Detect_Mode_Change
	PUSH {LR}

	MOV R1, #2_00000001 ; MASK -> Only get value of bit 0
	AND R1, R1, R0
	CMP R1, #2_00000001
	BLEQ Change_Mode

	POP {LR}
	BX LR

; Switches between operation modes
; Output: R8 -> New mode
Change_Mode
	PUSH {LR}
	BL Debounce_Buttons
	POP {LR}

	CMP R8, #MODE_PASSEIO_CAVALEIROS
	ITE EQ
		MOVEQ R8, #MODE_BINARY_COUNTER
		MOVNE R8, #MODE_PASSEIO_CAVALEIROS

; Every 100ms, expects buttons to be released before proceding
Debounce_Buttons
	PUSH {LR}

	; B Debounce_Buttons
	MOV R0, #100 ; Wait for 100 millis
	BL SysTick_Wait1ms

	BL Read_Buttons ; Read inputs again
	CMP R0, #2_00000000
	BNE Debounce_Buttons

	POP {LR}
	BX LR
; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
