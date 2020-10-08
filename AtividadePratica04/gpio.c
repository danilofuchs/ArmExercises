// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron

#include <stdint.h>

#include "tm4c1294ncpdt.h"

#define GPIO_PORTJ (0x0100) //bit 8   2_000000100000000
#define GPIO_PORTN (0x1000) //bit 12  2_001000000000000
#define GPIO_PORTF (0x0020) //bit 5   2_000000000100000

// -------------------------------------------------------------------------------
// Fun��o GPIO_Init
// Inicializa os ports J e N
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: N�o tem
void GPIO_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTF);
	//1b.   ap�s isso verificar no PRGPIO se a porta est� pronta para uso.
	while ((SYSCTL_PRGPIO_R & (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTF)) != (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTF))
	{
	};

	// 2. Limpar o AMSEL para desabilitar a anal�gica
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;

	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTJ_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for sa�da
	GPIO_PORTJ_AHB_DIR_R = 0x00;
	GPIO_PORTN_DIR_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x11; // BIT0 | BIT4

	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem fun��o alternativa
	GPIO_PORTJ_AHB_AFSEL_R = 0x00;
	GPIO_PORTN_AFSEL_R = 0x00;
	GPIO_PORTF_AHB_AFSEL_R = 0x00;

	// 6. Setar os bits de DEN para habilitar I/O digital
	GPIO_PORTJ_AHB_DEN_R = 0x03; //	BIT0 | BIT1
	GPIO_PORTN_DEN_R = 0x03;	 //	BIT0 | BIT1
	GPIO_PORTF_AHB_DEN_R = 0x11; //	BIT0 | BIT4

	// 7. Habilitar resistor de pull-up interno, setar PUR para 1
	GPIO_PORTJ_AHB_PUR_R = 0x03; //	BIT0 | BIT1

	/** INTERRUPTS */

	// 8. Desabilitar interrup��es no registrador IM
	GPIO_PORTJ_AHB_IM_R = 0x00; // Desabilita interrup��es

	// 9. Configurar tipo de interrup��o por borda no IS
	GPIO_PORTJ_AHB_IS_R = 0x00; // Por borda

	// 10. Configurar borda �nica no registrador IBE
	GPIO_PORTJ_AHB_IBE_R = 0x00; // Borda �nica

	// 11. Configurar bordas no registrador IEV
	GPIO_PORTJ_AHB_IEV_R = 0x00; // Borda de subida

	// 12. Realizar ACK
	GPIO_PORTJ_AHB_ICR_R = (1 << 1); // Limpar J1

	// 13. Habilita interrup��es no registrador IM
	GPIO_PORTJ_AHB_IM_R = (1 << 1); // Habilitar interrup��es em J1

	// Interrup��o 51 (PortJ)
	// 14. Setar prioridade no NVIC
	// PRI12 = Interrupt 48-51 Priority
	NVIC_PRI12_R = (3 << 29); // Prioridade 3 no interrupt 51 (4o byte do pri12)

	// 15. Habilitar interrup��o do grupo no NVIC
	// EN1 = Enables interrupts 32-63
	NVIC_EN1_R = (1 << 19); // queremos editar o 51 = (32 + 19)
}

// -------------------------------------------------------------------------------
// Fun��o PortJ_Input
// L� os valores de entrada do port J
// Par�metro de entrada: N�o tem
// Par�metro de sa�da: o valor da leitura do port
uint32_t PortJ_Input(void)
{
	return GPIO_PORTJ_AHB_DATA_R;
}

// -------------------------------------------------------------------------------
// Fun��o PortN_Output
// Escreve os valores no port N
// Par�metro de entrada: Valor a ser escrito
// Par�metro de sa�da: n�o tem
void PortN_Output(uint32_t valor)
{
	uint32_t temp;
	//vamos zerar somente os bits menos significativos
	//para uma escrita amig�vel nos bits 0 e 1
	temp = GPIO_PORTN_DATA_R & (~0x03);
	//agora vamos fazer o OR com o valor recebido na fun��o
	temp = temp | valor;
	GPIO_PORTN_DATA_R = temp;
}

// -------------------------------------------------------------------------------
// Fun��o PortF_Output
// Escreve os valores no port F
// Par�metro de entrada: Valor a ser escrito
// Par�metro de sa�da: n�o tem
void PortF_Output(uint32_t valor)
{
	uint32_t temp;
	//vamos zerar somente os bits menos significativos
	//para uma escrita amig�vel nos bits 0 e 4
	temp = GPIO_PORTF_AHB_DATA_R & (~0x11);
	//agora vamos fazer o OR com o valor recebido na fun��o
	temp = temp | valor;
	GPIO_PORTF_AHB_DATA_R = temp;
}

extern uint8_t pedestrianFlag;

// Fun��o GPIOPortJ_Handler
// Lida com interrupts no port J
// Seta flag externa pedestrianFlag
void GPIOPortJ_Handler(void)
{
	GPIO_PORTJ_AHB_ICR_R = (1 << 1); // Fazer ACK do bit 1 (J1)
	pedestrianFlag = 1;
}
