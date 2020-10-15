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
// Função GPIO_Init
// Inicializa os ports J e N
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Não tem
void GPIO_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTF);
	//1b.   após isso verificar no PRGPIO se a porta está pronta para uso.
	while ((SYSCTL_PRGPIO_R & (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTF)) != (GPIO_PORTJ | GPIO_PORTN | GPIO_PORTF))
	{
	};

	// 2. Limpar o AMSEL para desabilitar a analógica
	GPIO_PORTJ_AHB_AMSEL_R = 0x00;
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;

	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTJ_AHB_PCTL_R = 0x00;
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for saída
	GPIO_PORTJ_AHB_DIR_R = 0x00;
	GPIO_PORTN_DIR_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x11; // BIT0 | BIT4

	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem função alternativa
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

	// 8. Desabilitar interrupções no registrador IM
	GPIO_PORTJ_AHB_IM_R = 0x00; // Desabilita interrupções

	// 9. Configurar tipo de interrupção por borda no IS
	GPIO_PORTJ_AHB_IS_R = 0x00; // Por borda

	// 10. Configurar borda única no registrador IBE
	GPIO_PORTJ_AHB_IBE_R = 0x00; // Borda única

	// 11. Configurar bordas no registrador IEV
	GPIO_PORTJ_AHB_IEV_R = 0x00; // Borda de subida

	// 12. Realizar ACK
	GPIO_PORTJ_AHB_ICR_R = (1 << 0); // Limpar J0

	// 13. Habilita interrupções no registrador IM
	GPIO_PORTJ_AHB_IM_R = (1 << 0); // Habilitar interrupções em J0

	// Interrupção 51 (PortJ)
	// 14. Setar prioridade no NVIC
	// PRI12 = Interrupt 48-51 Priority
	NVIC_PRI12_R = (3 << 29); // Prioridade 3 no interrupt 51 (4o byte do pri12)

	// 15. Habilitar interrupção do grupo no NVIC
	// EN1 = Enables interrupts 32-63
	NVIC_EN1_R = (1 << 19); // queremos editar o 51 = (32 + 19)

	/** TIMERS */
	// Usando timer 2 - Modo 32 bits

	// 1. Habilitar o respectivo timer no registrador RCGCTIMER
	uint8_t enabledTimers = (1 << 2); // Ativar o timer 2
	SYSCTL_RCGCTIMER_R = enabledTimers;

	// esperar até que o respectivo timer esteja pronto para ser acessado
	while ((SYSCTL_PRTIMER_R & enabledTimers) != enabledTimers)
	{
	};

	// 2. Garantir que o timer esteja desabilitado antes de fazer as alterações
	TIMER2_CTL_R = 0x0; // Reset - Timer desligado

	// 3. Colocar o timer no modo 16 ou 32 bits escrevendo 0x4 ou 0x0 no registrador GPTMCFG
	TIMER2_CFG_R = 0x0; // 32 bits

	// 4. Configurar o campo TnMR para 0x1 no registrador GPTMTnMR
	TIMER2_TAMR_R = 0x2; // Periódico

	// 5. Carregar o valor de contagem no registrador timerA no registrador GPTMTAILR
	TIMER2_TAILR_R = 55999999; // Em 80Mhz, equivale a 700ms

	// 6. Como não temos prescale, deixar o registrador GPTMTAPR zerado.
	TIMER2_TAPR_R = 0x0;

	// 7. Como vamos utilizar o timerA, setar o bit
	// 		TnTOCINT no registrador GPTMICR, para
	// 		garantir que a primeira interrupção seja atendida.

	TIMER2_ICR_R = 0x1; // zerar o flag de atendimento de interrupção (ACK)

	// 8.a) Como vamos utilizar interrupção para estouro
	//		do timer, escrever 1 no bit TATOIM do registrador
	//		GPTMIMR
	TIMER2_IMR_R = 0x1;

	// 8.b) Setar a prioridade da interrupção do timer respectivo
	//		no respectivo registrador NVIC Priority Register.
	// Timer 2A = Interrupção 23
	// PRI5 = Interrupts 20-23
	NVIC_PRI5_R = (uint32_t)(0x4 << 29); // Setar prioridade 4 para o 4o interrupt do PRI5

	// 8.c) Habilitar a interrupção do timer respectivo no
	//		respectivo registrador NVIC Interrupt Enable Register
	// Timer 2A = Interrupção 23
	// EN0 = Interrupts 0-31
	NVIC_EN0_R = 1 << 23;

	// 9. Habilitar o bit TAEN no registrador GPTMCTL para começar o timer.
	TIMER2_CTL_R = 0x1; // Timer ligado
}

// -------------------------------------------------------------------------------
// Função PortJ_Input
// Lê os valores de entrada do port J
// Parâmetro de entrada: Não tem
// Parâmetro de saída: o valor da leitura do port
uint32_t PortJ_Input(void)
{
	return GPIO_PORTJ_AHB_DATA_R;
}

// -------------------------------------------------------------------------------
// Função PortN_Output
// Escreve os valores no port N
// Parâmetro de entrada: Valor a ser escrito
// Parâmetro de saída: não tem
void PortN_Output(uint32_t valor)
{
	uint32_t temp;
	//vamos zerar somente os bits menos significativos
	//para uma escrita amigável nos bits 0 e 1
	temp = GPIO_PORTN_DATA_R & (~0x03);
	//agora vamos fazer o OR com o valor recebido na função
	temp = temp | valor;
	GPIO_PORTN_DATA_R = temp;
}

// -------------------------------------------------------------------------------
// Função PortF_Output
// Escreve os valores no port F
// Parâmetro de entrada: Valor a ser escrito
// Parâmetro de saída: não tem
void PortF_Output(uint32_t valor)
{
	uint32_t temp;
	//vamos zerar somente os bits menos significativos
	//para uma escrita amigável nos bits 0 e 4
	temp = GPIO_PORTF_AHB_DATA_R & (~0x11);
	//agora vamos fazer o OR com o valor recebido na função
	temp = temp | valor;
	GPIO_PORTF_AHB_DATA_R = temp;
}

extern uint8_t timerToggle;

// Função GPIOPortJ_Handler
// Lida com interrupts no port J
// Seta flag externa timerEnabled
void GPIOPortJ_Handler(void)
{
	GPIO_PORTJ_AHB_ICR_R = (1 << 0); // Fazer ACK do bit 0 (J0)
	timerToggle = !timerToggle;
}

extern uint8_t ledOn;

// Função Timer2A_Handler
// Lida com interrupts do timer 2A
// Seta flag externa timedOut
void Timer2A_Handler(void)
{
	TIMER2_ICR_R = (1 << 0); // Fazer ACK do timer (bit 0)
	ledOn = !ledOn;
}

void enableTimer(void)
{
	TIMER2_CTL_R = 0x1;
}

void disableTimer(void)
{
	TIMER2_CTL_R = 0x0;
}