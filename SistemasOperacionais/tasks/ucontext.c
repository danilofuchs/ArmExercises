// #pragma ARM
#include "ucontext.h"
extern set_context_asm(ucontext_t *);
extern get_context_asm(ucontext_t *);

void makecontext(ucontext_t *context, int start_routine, int n_params, char *param)
{
  context->func = start_routine;
  context->uc_mcontext.regR0 = (int)param;
}

int swapcontext(ucontext_t *saida, ucontext_t *entrada)
{
  get_context_asm(saida);
  set_context_asm(entrada);

  return 0;
}

int getcontext(ucontext_t *context)
{
  return get_context_asm(context);
}

int setcontext(ucontext_t *context)
{
  return set_context_asm(context);
}
