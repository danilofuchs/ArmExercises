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
        IMPORT  PortJ_Input	


; -------------------------------------------------------------------------------
; Função main()
Start  		
	BL PLL_Init                  ;Chama a subrotina para alterar o clock do microcontrolador para 80MHz
	BL SysTick_Init              ;Chama a subrotina para inicializar o SysTick
	BL GPIO_Init                 ;Chama a subrotina que inicializa os GPIO
	MOV R10, #2_00000000		 ; Estado inicial das portas N

MainLoop
; ****************************************
; Escrever código que lê o estado da chave, se ela estiver desativada apaga o LED
; Se estivar ativada chama a subrotina Pisca_LED
; ****************************************
	BL Display_LED
	BL Wait_1000ms
	BL Read_Button
	BL Flip_LED_If_Button_Pressed
	B MainLoop

;--------------------------------------------------------------------------------
; Função Display_LED
; Parâmetro de entrada: Não tem
; Parâmetro de saída: Não tem
Display_LED
; ****************************************
; Escrever função que acende o LED, espera 1 segundo, apaga o LED e espera 1 s
; Esta função deve chamar a rotina SysTick_Wait1ms com o parâmetro de entrada em R0
; ****************************************

	PUSH {LR}

	MOV R0, R10 ; Display onto port N via R0
	BL PortN_Output

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

; Args: R0 -> Is button pressed? 0 = false, 1 = true
Flip_LED_If_Button_Pressed
	PUSH {LR}

	CMP R0, #1
	BLEQ Flip_LED

	POP {LR}
	BX LR

; Flips bit 1 of register R10
Flip_LED
	; Flip a single bit:
	MOV R1, #2_00000010 ; MASK -> Flip only bit 1
	EOR R10, R1, R10

; -------------------------------------------------------------------------------------------------------------------------
; Fim do Arquivo
; -------------------------------------------------------------------------------------------------------------------------	
    ALIGN                        ;Garante que o fim da seção está alinhada 
    END                          ;Fim do arquivo
