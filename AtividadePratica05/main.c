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
void enableTimer(void);
void disableTimer(void);

void Display_Array(uint8_t arr[4]);

// ===  Local prototypes ===

// === Global variables ===
uint8_t timerToggle = 0;
uint8_t ledOn = 0;

// ===  Main ===
int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();

	uint8_t timerEnabled = 0;

	while (1)
	{
		if (timerToggle != timerEnabled)
		{
			// Syncronizes timer state with user toggle
			if (timerToggle)
			{
				enableTimer();
			}
			else
			{
				disableTimer();
			}
			timerEnabled = timerToggle;
		}

		if (ledOn)
		{
			Display_Array((uint8_t[4]){1, 0, 0, 0});
		}
		else
		{
			Display_Array((uint8_t[4]){0, 0, 0, 0});
		}
	}
}
