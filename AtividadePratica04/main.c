// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Verifica o estado das chaves USR_SW1 e USR_SW2, acende os LEDs 1 e 2 caso estejam pressionadas independentemente
// Caso as duas chaves estejam pressionadas ao mesmo tempo pisca os LEDs alternadamente a cada 500ms.
// Prof. Guilherme Peron

#include <stdint.h>

void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
uint32_t PortJ_Input(void);
void Display_Number(uint32_t number);
void Display_Array(uint8_t arr[4]);
void Pisca_leds(void);

int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();

	while (1)
	{

		Display_Array((uint8_t[4]){0, 1, 0, 1});
	}
}
