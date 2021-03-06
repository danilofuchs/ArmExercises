#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include "ppos.h"
#include "libraries/debug.h"

#define STACKSIZE 32768 /* tamanho de pilha das threads */

uint32_t task_id_counter = 1;
task_t main_task;
task_t *current_task = NULL;

// funções gerais ==============================================================

// Inicializa o sistema operacional; deve ser chamada no inicio do main()
void ppos_init()
{

    /* desativa o buffer da saida padrao (stdout), usado pela função printf */
    setvbuf(stdout, 0, _IONBF, 0);
    debug_fn_start("ppos_init");

    main_task.id = 0;
    getcontext(&(main_task.context));
    current_task = &main_task;

    debug_fn_return(NULL);
}

// gerência de tarefas =========================================================

// Cria uma nova tarefa. Retorna um ID > 0 ou erro.
int task_create(task_t *task,               // descritor da nova tarefa
                void (*start_func)(void *), // funcao corpo da tarefa
                void *arg                   // argumentos para a tarefa
)
{
    debug_fn_start("task_create");

    if (getcontext(&(task->context)) == -1)
    {
        debug_fn_return("Error (getcontext): %s", strerror(errno));
        return errno;
    }

    char *stack = (char *)malloc(STACKSIZE);

    if (!stack)
    {
        debug_fn_return("Error (malloc): %s", strerror(errno));
        return errno;
    }

    task->context.uc_stack.ss_sp = stack;
    task->context.uc_stack.ss_size = STACKSIZE;
    task->context.uc_stack.ss_flags = 0;
    task->context.uc_link = 0;

    makecontext(&(task->context), (void *)start_func, 1, arg);
    debug_fn_step("configured context");

    task->id = task_id_counter++;

    debug_fn_step("configured task");

    debug_fn_return("%d", task->id);
    return task->id;
}

// Termina a tarefa corrente, indicando um valor de status encerramento
void task_exit(int exitCode)
{
    debug_fn_start("task_exit");

    task_switch(&main_task);

    debug_fn_return(NULL);
}

// alterna a execução para a tarefa indicada
int task_switch(task_t *task)
{
    task_t *previous = current_task;
    debug_fn_start("task_switch");

    debug_fn_step("Switching tasks: %d -> %d", current_task->id, task->id);

    current_task = task;

    swapcontext(&(previous->context), &(task->context));

    debug_fn_return("%d", 0);
    return 0;
}

// retorna o identificador da tarefa corrente (main deve ser 0)
int task_id()
{
    return current_task->id;
}
