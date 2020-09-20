; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Ver 1 19/03/2018
; Ver 2 26/08/2018

; -------------------------------------------------------------------------------
        THUMB                        ; Instru��es do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declara��es EQU - Defines
; ========================
; ========================
; Defini��es dos Registradores Gerais
SYSCTL_RCGCGPIO_R	 EQU	0x400FE608
SYSCTL_PRGPIO_R		 EQU    0x400FEA08
; ========================
; Defini��es dos Ports
; PORT J
GPIO_PORTJ_AHB_LOCK_R    	EQU    0x40060520
GPIO_PORTJ_AHB_CR_R      	EQU    0x40060524
GPIO_PORTJ_AHB_AMSEL_R   	EQU    0x40060528
GPIO_PORTJ_AHB_PCTL_R    	EQU    0x4006052C
GPIO_PORTJ_AHB_DIR_R     	EQU    0x40060400
GPIO_PORTJ_AHB_AFSEL_R   	EQU    0x40060420
GPIO_PORTJ_AHB_DEN_R     	EQU    0x4006051C
GPIO_PORTJ_AHB_PUR_R     	EQU    0x40060510	
GPIO_PORTJ_AHB_DATA_R    	EQU    0x400603FC

GPIO_PORTJ_AHB_IM_R			EQU	   0x40060410
GPIO_PORTJ_AHB_IS_R     	EQU    0x40060404
GPIO_PORTJ_AHB_IBE_R    	EQU    0x40060408
GPIO_PORTJ_AHB_IEV_R    	EQU    0x4006040C
GPIO_PORTJ_AHB_ICR_R    	EQU    0x4006041C
GPIO_PORTJ               	EQU    2_000000100000000
; PORT N
GPIO_PORTN_AHB_LOCK_R    	EQU    0x40064520
GPIO_PORTN_AHB_CR_R      	EQU    0x40064524
GPIO_PORTN_AHB_AMSEL_R   	EQU    0x40064528
GPIO_PORTN_AHB_PCTL_R    	EQU    0x4006452C
GPIO_PORTN_AHB_DIR_R     	EQU    0x40064400
GPIO_PORTN_AHB_AFSEL_R   	EQU    0x40064420
GPIO_PORTN_AHB_DEN_R     	EQU    0x4006451C
GPIO_PORTN_AHB_PUR_R     	EQU    0x40064510	
GPIO_PORTN_AHB_DATA_R    	EQU    0x400643FC
GPIO_PORTN               	EQU    2_001000000000000
; NVIC
NVIC_PRI12_R				EQU	   0xE000E430
NVIC_EN1_R					EQU	   0xE000E104


; -------------------------------------------------------------------------------
; �rea de C�digo - Tudo abaixo da diretiva a seguir ser� armazenado na mem�ria de 
;                  c�digo
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma fun��o do arquivo for chamada em outro arquivo	
        EXPORT GPIO_Init            ; Permite chamar GPIO_Init de outro arquivo
		EXPORT PortN_Output			; Permite chamar PortN_Output de outro arquivo
		EXPORT GPIOPortJ_Handler    ; Gerenciador de interrup��es da porta J
									

;--------------------------------------------------------------------------------
; Fun��o GPIO_Init
; Par�metro de entrada: N�o tem
; Par�metro de sa�da: N�o tem
GPIO_Init
;=====================
; ****************************************
; Escrever fun��o de inicializa��o dos GPIO
; Inicializar as portas J e N
; ****************************************
			LDR     R0, =SYSCTL_RCGCGPIO_R  		;Carrega o endere�o do registrador RCGCGPIO
			MOV		R1, #GPIO_PORTJ                 ;Seta o bit da porta J
			ORR     R1, #GPIO_PORTN					;Seta o bit da porta N, fazendo com OR
			STR     R1, [R0]						;Move para a mem�ria os bits das portas no endere�o do RCGCGPIO

			LDR     R0, =SYSCTL_PRGPIO_R			;Carrega o endere�o do PRGPIO para esperar os GPIO ficarem prontos
EsperaGPIO  LDR     R1, [R0]						;L� da mem�ria o conte�do do endere�o do registrador
			MOV     R2, #GPIO_PORTJ                 ;Seta os bits correspondentes �s portas para fazer a compara��o
			ORR     R2, #GPIO_PORTN                 ;Seta o bit da porta N, fazendo com OR
			TST     R1, R2							;ANDS de R1 com R2
			BEQ     EsperaGPIO					    ;Se o flag Z=1, volta para o la�o. Sen�o continua executando

; 2. Limpar o AMSEL para desabilitar a anal�gica
            MOV     R1, #0x00						;Colocar 0 no registrador para desabilitar a fun��o anal�gica

            LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R     ;Carrega o R0 com o endere�o do AMSEL para a porta J
            STR     R1, [R0]						;Guarda no registrador AMSEL da porta J da mem�ria

            LDR     R0, =GPIO_PORTN_AHB_AMSEL_R		;Carrega o R0 com o endere�o do AMSEL para a porta N
            STR     R1, [R0]					    ;Guarda no registrador AMSEL da porta N da mem�ria

; 3. Limpar PCTL para selecionar o GPIO
            MOV     R1, #0x00					    ;Colocar 0 no registrador para selecionar o modo GPIO

            LDR     R0, =GPIO_PORTJ_AHB_PCTL_R		;Carrega o R0 com o endere�o do PCTL para a porta J
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta J da mem�ria

            LDR     R0, =GPIO_PORTN_AHB_PCTL_R      ;Carrega o R0 com o endere�o do PCTL para a porta N
            STR     R1, [R0]                        ;Guarda no registrador PCTL da porta N da mem�ria

; 4. DIR para 0 se for entrada, 1 se for sa�da
			; O certo era verificar os outros bits da PJ para n�o transformar entradas em sa�das desnecess�rias
            LDR     R0, =GPIO_PORTJ_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta J
            MOV     R1, #0x00               		;Colocar 0 no registrador DIR para funcionar como entrada
            STR     R1, [R0]						;Guarda no registrador PCTL da porta J da mem�ria
								
			LDR     R0, =GPIO_PORTN_AHB_DIR_R		;Carrega o R0 com o endere�o do DIR para a porta N
			MOV     R1, #2_00000010					;PN1 para LED
            STR     R1, [R0]						;Guarda no registrador

; 5. Limpar os bits AFSEL para 0 para selecionar GPIO 
;    Sem fun��o alternativa
            MOV     R1, #0x00						;Colocar o valor 0 para n�o setar fun��o alternativa

            LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R		;Carrega o endere�o do AFSEL da porta J
            STR     R1, [R0]						;Escreve na porta

            LDR     R0, =GPIO_PORTN_AHB_AFSEL_R     ;Carrega o endere�o do AFSEL da porta N
            STR     R1, [R0]                        ;Escreve na porta

; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTJ_AHB_DEN_R			;Carrega o endere�o do DEN
            MOV     R1, #2_00000011                     ;Ativa os pinos PJ1, PJ0 como I/O Digital
            STR     R1, [R0]							;Escreve no registrador da mem�ria funcionalidade digital 
 
            LDR     R0, =GPIO_PORTN_AHB_DEN_R			;Carrega o endere�o do DEN
			MOV     R1, #2_00000010                     ;Ativa o pino PN1 como I/O Digital      
            STR     R1, [R0]                            ;Escreve no registrador da mem�ria funcionalidade digital

; 7. Para habilitar resistor de pull-up interno, setar PUR para 1
			LDR     R0, =GPIO_PORTJ_AHB_PUR_R			;Carrega o endere�o do PUR para a porta J
			MOV     R1, #2_00000011						;Habilitar funcionalidade digital de resistor de pull-up 
                                                        ;nos bits 0 e 1
            STR     R1, [R0]							;Escreve no registrador da mem�ria do resistor de pull-up

; Interrupts
; 8. Desabilitar interrup��es no registrador IM
			LDR 	R0, =GPIO_PORTJ_AHB_IM_R			;Carrega o endereco de IM da porta J
			MOV		R1, #2_00							; Desabilita interrup��es
			STR		R1, [R0]

; 9. Configurar tipo de interrup��o por borda no IS
			LDR 	R0, =GPIO_PORTJ_AHB_IS_R			;Carrega o endereco de IS da porta J
			MOV		R1, #2_00							; Por borda
			STR		R1, [R0]

; 10. Configurar borda �nica no registrador IBE
			LDR 	R0, =GPIO_PORTJ_AHB_IBE_R			;Carrega o endereco de IBE da porta J
			MOV		R1, #2_00							; Borda �nica
			STR		R1, [R0]

; 11. Configurar borda de descida (bot�o pressionado) no registrador IEV
			LDR 	R0, =GPIO_PORTJ_AHB_IEV_R			;Carrega o endereco de IEV da porta J
			MOV		R1, #2_00							; Borda de descida
			STR		R1, [R0]

; 12. Habilita interrup��es no registrador IM
			LDR 	R0, =GPIO_PORTJ_AHB_IM_R			;Carrega o endereco de IEV da porta J
			MOV		R1, #2_01							; Habilitar
			STR		R1, [R0]

; Interrup��o 51 (PortJ)
; 13. Setar prioridade no NVIC
			LDR		R0, =NVIC_PRI12_R					; PRI12 = Interrupt 48-51 Priority
			MOV		R1, #3								; Prioridade 3
			LSL		R1, R1, #29							; Desloca 29 bits para esquerda j� que o J � o �ltimo byte do PRI12
			STR		R1, [R0]

; 14. Habilitar interrup��o do grupo no NVIC
			LDR		R0, =NVIC_EN1_R						; EN2 = Enables interrupts 32-63
			MOV		R1, #1								; Habilitar
			LSL		R1, #19								; Desloca 19 bits para esquerda j� que queremos editar o 51 = (32 + 19)
			STR		R1, [R0]

;retorno            
			BX      LR

; -------------------------------------------------------------------------------
; Fun��o PortN_Output
; Par�metro de entrada: R0 --> se o LED est� ligado
; Par�metro de sa�da: N�o tem
PortN_Output
; ****************************************
; Escrever fun��o que acende ou apaga o LED
; ****************************************
	LDR	R1, =GPIO_PORTN_AHB_DATA_R		    ;Carrega o valor do offset do data register
	;Read-Modify-Write para escrita
	LDR R2, [R1]
	BIC R2, #2_00000010                     ;Primeiro limpamos os dois bits do lido da porta R2 = R2 & 11111110
	ORR R0, R0, R2                          ;Fazer o OR do lido pela porta com o par�metro de entrada
	STR R0, [R1]                            ;Escreve na porta N o barramento de dados dos pinos N1 e N0
	BX LR                                   ;Retorno


GPIOPortJ_Handler
	LDR	R1, =GPIO_PORTJ_AHB_ICR_R
	MOV R0, #2_00000001						; Fazendo ACK do bit 0 do PortJ
	STR R0, [R1]

	BX LR									;Retorno

    ALIGN                           ; garante que o fim da se��o est� alinhada 
    END                             ; fim do arquivo