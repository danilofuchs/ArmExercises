#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>

#include "debug.h"
#include "utils/uartstdio.h"

void debug_fn_start(char *fn_name)
{
#ifdef DEBUG
    UARTprintf("┌ [%s]\n", fn_name);
#endif
}

void debug_fn_step(const char *format, ...)
{
#ifdef DEBUG
    va_list args;
    va_start(args, format);
    char text[255];
    vsprintf(text, format, args);
    va_end(args);

    UARTprintf("│ %s\n", text);
#endif
}

void debug_fn_return(const char *format, ...)
{
#ifdef DEBUG
    if (!format)
    {
        UARTprintf("└───\n");
        return;
    }
    va_list args;
    va_start(args, format);
    char returned_value[255];
    vsprintf(returned_value, format, args);
    va_end(args);

    UARTprintf("└─→ %s\n", returned_value);
#endif
}
