// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Um timer com período de 700ms pisca um LED
// periodicamente através de interrupções.
// Cliques no botão SW1 ativam/desativam o timer
//
// Danilo Fuchs

#include <stdint.h>

// === Imported prototypes ===
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void setDutyCycle(uint8_t dutyCycle);
void initPWM(void);

void Display_Array(uint8_t arr[4]);

uint8_t hasItemsToReceive(void);
uint8_t inChar(void);

uint8_t canTransmit(void);
void outChar(uint8_t item);

// ===  Local prototypes ===

// === Global variables ===
uint8_t ledOn = 0;

// ===  Main ===
int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();

	// setDutyCycle(50);
	// initPWM();

	// outChar('a');
	// outChar('b');
	// outChar('c');
	// outChar('1');
	// outChar('2');
	// outChar('3');

	while (1)
	{

		// if (hasItemsToReceive())
		// {
		uint8_t character = inChar();
		if (character == '1')
		{
			Display_Array((uint8_t[4]){1, 0, 0, 0});
		}
		else
		{
			Display_Array((uint8_t[4]){0, 0, 0, 0});
		}
		// }
		// if (ledOn)
		// {
		// 	Display_Array((uint8_t[4]){1, 0, 0, 0});
		// }
		// else
		// {
		// 	Display_Array((uint8_t[4]){0, 0, 0, 0});
		// }
	}
}
