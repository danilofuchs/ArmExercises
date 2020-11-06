// gpio.c
// Desenvolvido para a placa EK-TM4C1294XL
// Inicializa as portas J e N
// Prof. Guilherme Peron

#include <stdint.h>

#include "tm4c1294ncpdt.h"

#define GPIO_PORTN (1 << 12) //bit 12  2_001000000000000
#define GPIO_PORTF (1 << 5)	 //bit 5   2_000000000100000
#define GPIO_PORTA (1 << 0)	 //bit 0   2_000000000000001

// -------------------------------------------------------------------------------
// Função GPIO_Init
// Inicializa os ports J e N
// Parâmetro de entrada: Não tem
// Parâmetro de saída: Não tem
void GPIO_Init(void)
{
	//1a. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO
	SYSCTL_RCGCGPIO_R = (GPIO_PORTN | GPIO_PORTF);
	//1b.   após isso verificar no PRGPIO se a porta está pronta para uso.
	while ((SYSCTL_PRGPIO_R & (GPIO_PORTN | GPIO_PORTF)) != (GPIO_PORTN | GPIO_PORTF))
	{
	};

	// 2. Limpar o AMSEL para desabilitar a analógica
	GPIO_PORTN_AMSEL_R = 0x00;
	GPIO_PORTF_AHB_AMSEL_R = 0x00;

	// 3. Limpar PCTL para selecionar o GPIO
	GPIO_PORTN_PCTL_R = 0x00;
	GPIO_PORTF_AHB_PCTL_R = 0x00;

	// 4. DIR para 0 se for entrada, 1 se for saída
	GPIO_PORTN_DIR_R = 0x03;	 // BIT0 | BIT1
	GPIO_PORTF_AHB_DIR_R = 0x11; // BIT0 | BIT4

	// 5. Limpar os bits AFSEL para 0 para selecionar GPIO sem função alternativa
	GPIO_PORTN_AFSEL_R = 0x00;
	GPIO_PORTF_AHB_AFSEL_R = 0x00;

	// 6. Setar os bits de DEN para habilitar I/O digital
	GPIO_PORTN_DEN_R = 0x03;	 //	BIT0 | BIT1
	GPIO_PORTF_AHB_DEN_R = 0x11; //	BIT0 | BIT4

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

	// 4. Configurar o campo TnMR para 0x1 no registrador GPTMTnMR para One Shot
	TIMER2_TAMR_R = 0x1; // One shot

	// 5. Carregar o valor de contagem no registrador timerA no registrador GPTMTAILR
	// TIMER2_TAILR_R = 55999999; // Em 80Mhz, equivale a 700ms

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
	// TIMER2_CTL_R = 0x1; // Timer ligado

	/** UART */
	// 1. Habilitar o clock no módulo UART no registrador
	// 		RCGCUART (cada bit representa uma UART)
	uint8_t enabledUarts = (1 << 0); // Ativar UART 0
	SYSCTL_RCGCUART_R = enabledUarts;

	// 		esperar até que a respectiva UART esteja pronta
	// para ser acessada no registrador PRUART (cada
	// bit representa uma UART).
	while ((SYSCTL_PRUART_R & enabledUarts) != enabledUarts)
	{
	};

	// 2. Garantir que a UART esteja desabilitada antes de
	// 		fazer as alterações (limpar o bit UARTEN) no
	// 		registrador UARTCTL (Control).
	UART0_CTL_R = 0x0; // Desabilitar UART

	// 3. Escrever o baud-rate nos registradores
	//		UARTIBRD e UARTFBRD

	// baud rate = 9600 bps
	// freq = 80MHz
	// BRD = 80000000/(16*9600) = 520,833333
	// UARTIBRD = 520
	// UARTFBRD = int(BFDF*64 + 0.5) = 0,833333*64 + 0,5 = 53,83 = 53
	UART0_IBRD_R = 520;
	UART0_FBRD_R = 53;

	// 4. Configurar o registrador UARTLCRH para o
	// 		número de bits, paridade, stop bits e fila
	UART0_LCRH_R = (3 << 5) | (1 << 4); // 8-bit, filas habilitadas e paridade impar habilitada

	// 5. Garantir que a fonte de clock seja o clock do
	// 		sistema no registrador UARTCC escrevendo 0
	// 		(ou escolher qualquer uma das outras fontes de
	// 		clock)
	UART0_CC_R = 0x0; // System clock (80 MHz)

	// 6. Habilitar as flags RXE, TXE e UARTEN no
	// 		registrador UARTCTL (habilitar a recepção,
	// 		transmissão e a UART)
	UART0_CTL_R = (1 << 9) | (1 << 8) | (1 << 0); // Habilita RX, TX e UART

	// 7. Habilitar o clock no módulo GPIO no registrador
	// 		RCGGPIO (cada bit representa uma GPIO) e
	// 		esperar até que a respectiva GPIO esteja pronta
	// 		para ser acessada no registrador PRGPIO (cada
	// 		bit representa uma GPIO).
	SYSCTL_RCGCGPIO_R |= GPIO_PORTA;
	while (SYSCTL_RCGCGPIO_R & GPIO_PORTA != GPIO_PORTA)
	{
	}

	// 8. Desabilitar a funcionalidade analógica no
	//		registrador GPIOAMSEL.
	GPIO_PORTA_AHB_AMSEL_R = 0x0;

	// 9. Escolher a função alternativa dos pinos
	//		respectivos TX e RX no registrador GPIOPCTL
	GPIO_PORTA_AHB_PCTL_R = (1 << 4) | (1 << 0); // Função UART RX e TX nos pinos A1 e A0

	// 	10. Habilitar os bits de função alternativa no
	// 		registrador GPIOAFSEL nos pinos respectivos à
	//		UART.
	GPIO_PORTA_AHB_AFSEL_R = (1 << 1) | (1 << 0); // Habilita função alternativa em A1 e A0

	// 	11. Configurar os pinos como digitais no registrador
	// 		GPIODEN.
	GPIO_PORTA_AHB_DEN_R = (1 << 1) | (1 << 0); // Funções digitais em A1 e A0
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

uint8_t ledOn = 0;

uint32_t highTicks = 0;
uint32_t lowTicks = 0;

// Função Timer2A_Handler
// Lida com interrupts do timer 2A
// Seta flag externa ledOn
void Timer2A_Handler(void)
{
	TIMER2_ICR_R = (1 << 0); // Fazer ACK do timer (bit 0)

	if (ledOn)
	{
		ledOn = 0;
		PortN_Output(0x0);
		TIMER2_TAILR_R = lowTicks;
	}
	else
	{
		ledOn = 1;
		PortN_Output(1 << 1);
		TIMER2_TAILR_R = highTicks;
	}

	TIMER2_CTL_R = 1;
}

void setDutyCycle(uint8_t dutyCycle)
{
	if (dutyCycle > 100)
	{
		dutyCycle = 100;
	}

	highTicks = 80000 * dutyCycle / 100;
	lowTicks = 80000 * (100 - dutyCycle) / 100;
}

void initPWM(void)
{
	ledOn = 1;
	PortN_Output(1 << 1);
	TIMER2_TAILR_R = highTicks;
	TIMER2_CTL_R = 1;
}

uint8_t inChar(void)
{
	while ((UART0_FR_R & UART_FR_RXFE) != 0)
	{
	};
	return UART0_DR_R;
}

void outChar(uint8_t data)
{
	while ((UART0_FR_R & UART_FR_TXFF) != 0)
	{
	};

	UART0_DR_R = data;
}

void outString(char *ptr)
{
	while (*ptr != '\0')
	{
		outChar((uint8_t)*ptr);
		ptr++;
	}
}
