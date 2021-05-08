#ifndef __DEBUG__
#define __DEBUG__

// Uncomment to debug
// #define DEBUG 1

// Prints a statement saying a function was called. Only runs with DEBUG is defined
void debug_fn_start(char *fn_name);
// Prints in the current function context, started with `debug_fn_start`. Only runs with DEBUG is defined
void debug_fn_step(const char *format, ...);
// Closes the current function debug log with the return value.
// If the function returns `void`, call with NULL.
// Only runs with DEBUG is defined
void debug_fn_return(const char *format, ...);

#endif