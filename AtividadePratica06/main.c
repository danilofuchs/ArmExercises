// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// LED na porta N1 acende com diferentes níveis de brilho
// Controlado por porta serial
// UART com baud rate de 9600
// Comandos reconhecidos:
// 		0 -> LED a 1%
// 		1 -> LED a 20%
// 		2 -> LED a 40%
// 		3 -> LED a 60%
// 		4 -> LED a 80%
// 		5 -> LED a 99%
//
// Danilo Fuchs

#include <stdint.h>
#include <stdio.h>

// === Imported prototypes ===
void PLL_Init(void);
void GPIO_Init(void);

void setDutyCycle(uint8_t dutyCycle);
void initPWM(void);

void Display_Array(uint8_t arr[4]);

uint8_t inChar(void);
void outString(char *ptr);

// ===  Local prototypes ===
void printChange(uint8_t percentage);
void printStart(uint8_t percentage);

// ===  Main ===
int main(void)
{
	PLL_Init();
	GPIO_Init();

	printStart(1);
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

void printStart(uint8_t percentage)
{
	char str[16];

	sprintf(str, "\r\nStart %2d%%", percentage);

	outString(str);
}

void printChange(uint8_t percentage)
{
	char str[16];

	sprintf(str, "\r\nLED a %2d%%", percentage);

	outString(str);
}
