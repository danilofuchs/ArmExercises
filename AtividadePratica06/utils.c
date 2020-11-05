#include <stdint.h>

void PortN_Output(uint32_t leds);
void PortF_Output(uint32_t leds);

// Writes 4-bit number into board's 4 LEDs
// Requires Port N and Port F to be setup
// as digital outputs
//
// number[3] => PN1
// number[2] => PN0
// number[1] => PF4
// number[0] => PF0
void Display_Number(uint32_t number)
{
    uint8_t bit0 = (number >> 0) & 1;
    uint8_t bit1 = (number >> 1) & 1;
    uint8_t bit2 = (number >> 2) & 1;
    uint8_t bit3 = (number >> 3) & 1;

    uint32_t portF = (bit1 << 4) | (bit0);
    PortF_Output(portF);

    uint32_t portN = (bit3 << 1) | (bit2);
    PortN_Output(portN);
}

// Writes 4-bit array into board's 4 LEDs
// Requires Port N and Port F to be setup
// as digital outputs
//
// arr[0] => PN1
// arr[1] => PN0
// arr[2] => PF4
// arr[3] => PF0
void Display_Array(uint8_t arr[4])
{
    uint32_t portF = (arr[2] << 4) | (arr[3]);
    PortF_Output(portF);

    uint32_t portN = (arr[0] << 1) | (arr[1]);
    PortN_Output(portN);
}
