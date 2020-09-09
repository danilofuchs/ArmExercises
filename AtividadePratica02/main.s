; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018
; Este programa deve esperar o usu�rio pressionar uma chave.
; Caso o usu�rio pressione uma chave, um LED deve piscar a cada 1 segundo.

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
		
; Declara��es EQU - Defines
;<NOME>         EQU <VALOR>
; ========================
; Defini��es de Valores


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
        EXPORT Start                ; Permite chamar a fun��o Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma fun��o externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; fun��o <func>
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
; Fun��o main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	MOV R9, #MODE_PASSEIO_CAVALEIROS		; R9 = MODE_SELECT
	MOV R10, #1000		 					; R10 = SPEED (ms)
	MOV R11, #2_00000000		 			; R11 = STATE PASSEIO CAVALEIROS

MainLoop
; ****************************************
; Escrever c�digo que l� o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************
	; BL Read_Button

	MOV R0, #2_1010
	BL Display_LED

	; BL Wait_1000ms
	; BL Flip_LED_If_Button_Pressed
	B MainLoop

;--------------------------------------------------------------------------------
; Fun��o Display_LED
; Par�metro de entrada: R0: 4-bit data to be displayed
; Par�metro de sa�da: N�o tem
Display_LED
	PUSH {LR}

	; R0[3] => PN1
	; R0[2] => PN0
	; R0[1] => PF4
	; R0[0] => PF0

	MOV R1, #2_00001100 ; MASK -> Get 3, 2
	AND R1, R1, R0 ; Get info from first 2 bits
	LSR R1, R1, #2 ; Shift these two bits from 3, 2 -> 1, 0

	MOV R0, R1 	; Display result in port N via R0
	BL PortN_Output

	MOV R2, #2_00000000

	MOV R1, #2_00000010 	; MASK -> Get bit 1
	AND R1, R1, R0 			; Get info from bit 1
	CMP R1, #2_00000010
	IT EQ
		ORREQ R2, #2_00010000 ; Set PF4
	
	MOV R1, #2_00000001 	; MASK -> Get bit 0
	AND R1, R1, R0 			; Get info from bit 0
	ORR R2, R1				; Set PF0 = R0[0]

	MOV R0, R2 	; Display result in port F via R0
	BL PortF_Output

	POP {LR}
	BX LR

Wait_1000ms
	PUSH {LR}

	MOV R0, #1000 ; Wait for 1000ms
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
    ALIGN                        ;Garante que o fim da se��o est� alinhada 
    END                          ;Fim do arquivo
