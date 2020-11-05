// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Um timer com período de 700ms pisca um LED
// periodicamente através de interrupções.
// Cliques no botão SW1 ativam/desativam o timer
//
// Danilo Fuchs

#include <stdint.h>
#include <stdio.h>

// === Imported prototypes ===
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);
void setDutyCycle(uint8_t dutyCycle);
void initPWM(void);

void Display_Array(uint8_t arr[4]);

uint8_t inChar(void);
void outString(char *ptr);

// ===  Local prototypes ===
void printChange(uint8_t percentage);

// === Global variables ===
uint8_t ledOn = 0;

// ===  Main ===
int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();
	
	outString("\r\nStart 1%%");

	setDutyCycle(1);
	initPWM();

	while (1)
	{
		uint8_t character = inChar();
		switch (character)
		{
		case '0':
			setDutyCycle(1);
			printChange(1);
			break;
		case '1':
			setDutyCycle(20);
			printChange(20);
			break;
		case '2':
			setDutyCycle(40);
			printChange(40);
			break;
		case '3':
			setDutyCycle(60);
			printChange(60);
			break;
		case '4':
			setDutyCycle(80);
			printChange(80);
			break;
		case '5':
			setDutyCycle(99);
			printChange(99);
			break;
		default:
			break;
		}
	}
}

void printChange(uint8_t percentage)
{
	char str[16];

	sprintf(str, "\r\nLED a %2d%%", percentage);

	outString(str);
}
