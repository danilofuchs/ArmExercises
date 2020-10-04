// main.c
// Desenvolvido para a placa EK-TM4C1294XL
// Simula comportamento de dois semáforos, através de uma máquina de estados
// Em nenhum momento ambos os semáforos são verdes.
// Há um período em que ambos estão vermelhos logo após o fechamento de um deles.
//
// Danilo Fuchs

#include <stdint.h>

// === Imported prototypes ===
void PLL_Init(void);
void SysTick_Init(void);
void SysTick_Wait1ms(uint32_t delay);
void GPIO_Init(void);

uint32_t PortJ_Input(void);

void Display_Array(uint8_t arr[4]);

// ===  Local prototypes ===
typedef enum State
{
	BothRedBeforeS2Green,
	S2Green,
	S2Yellow,
	BothRedBeforeS1Green,
	S1Green,
	S1Yellow
} State;

void performStateActions(State state);
State performStateTransitions(State state);

// ===  Main ===
int main(void)
{
	PLL_Init();
	SysTick_Init();
	GPIO_Init();

	State state = BothRedBeforeS2Green;

	while (1)
	{
		performStateActions(state);
		state = performStateTransitions(state);
	}
}

void performStateActions(State state)
{
	switch (state)
	{
	case BothRedBeforeS2Green:
		Display_Array((uint8_t[4]){1, 1, 1, 1});
		SysTick_Wait1ms(1000);
		break;
	case S2Green:
		Display_Array((uint8_t[4]){1, 1, 1, 0});
		SysTick_Wait1ms(6000);
		break;
	case S2Yellow:
		Display_Array((uint8_t[4]){1, 1, 0, 1});
		SysTick_Wait1ms(2000);
		break;
	case BothRedBeforeS1Green:
		Display_Array((uint8_t[4]){1, 1, 1, 1});
		SysTick_Wait1ms(1000);
		break;
	case S1Green:
		Display_Array((uint8_t[4]){1, 0, 1, 1});
		SysTick_Wait1ms(6000);
		break;
	case S1Yellow:
		Display_Array((uint8_t[4]){0, 1, 1, 1});
		SysTick_Wait1ms(2000);
		break;
	}
}

State performStateTransitions(State state)
{
	switch (state)
	{
	case BothRedBeforeS2Green:
		return S2Green;
	case S2Green:
		return S2Yellow;
	case S2Yellow:
		return BothRedBeforeS1Green;
	case BothRedBeforeS1Green:
		return S1Green;
	case S1Green:
		return S1Yellow;
	case S1Yellow:
		return BothRedBeforeS2Green;
	}
	return BothRedBeforeS2Green;
}
