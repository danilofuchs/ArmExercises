#include "debug.h"
#include <stdio.h>
#include <stdarg.h>

void debug_fn_start(char *fn_name)
{
#ifdef DEBUG
    printf("┌ [%s]\n", fn_name);
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

    printf("│ %s\n", text);
#endif
}

void debug_fn_return(const char *format, ...)
{
#ifdef DEBUG
    if (!format)
    {
        printf("└───\n");
        return;
    }
    va_list args;
    va_start(args, format);
    char returned_value[255];
    vsprintf(returned_value, format, args);
    va_end(args);

    printf("└─🡒 %s\n", returned_value);
#endif
}