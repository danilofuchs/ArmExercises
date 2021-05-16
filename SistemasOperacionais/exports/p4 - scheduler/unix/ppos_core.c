#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdint.h>
#include "ppos.h"
#include "libraries/debug.h"
#include "libraries/queue.h"

#define STACKSIZE 32768 /* tamanho de pilha das threads */
#define SCHEDULER_AGING_ALPHA 1

task_t dispatcher_task;

uint32_t task_id_counter = 1;
task_t main_task;
task_t *current_task = NULL;

task_t *ready_queue = NULL;

void dispatcher();

void print_task(void *ptr)
{
    task_t *task = ptr;
    printf("%d", task->id);
}

// funções gerais ==============================================================

// Inicializa o sistema operacional; deve ser chamada no inicio do main()
void ppos_init()
{

    /* desativa o buffer da saida padrao (stdout), usado pela função printf */
    setvbuf(stdout, 0, _IONBF, 0);
    debug_fn_start("ppos_init");

    main_task.id = 0;
    main_task.prev = NULL;
    main_task.next = NULL;
    getcontext(&(main_task.context));
    current_task = &main_task;

    task_create(&dispatcher_task, dispatcher, NULL);

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

    task_setprio(task, 0);

    makecontext(&(task->context), (void *)start_func, 1, arg);
    debug_fn_step("configured context");

    task->id = task_id_counter++;
    task->state = CREATED;

    debug_fn_step("configured task");

    if (task != &dispatcher_task)
    {
        task->state = READY;
        queue_append((queue_t **)&ready_queue, (queue_t *)task);
        debug_fn_step("added to ready queue");
    }

    // queue_print("Ready queue", (queue_t *)ready_queue, print_task);

    debug_fn_return("%d", task->id);
    return task->id;
}

// Termina a tarefa corrente, indicando um valor de status encerramento
void task_exit(int exitCode)
{
    debug_fn_start("task_exit");

    current_task->state = TERMINATED;

    if (current_task == &dispatcher_task)
    {
        task_switch(&main_task);
    }
    else
    {
        task_switch(&dispatcher_task);
    }

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

void task_yield()
{
    current_task->state = READY;
    task_switch(&dispatcher_task);
}

// retorna o identificador da tarefa corrente (main deve ser 0)
int task_id()
{
    return current_task->id;
}

void task_setprio(task_t *task, int prio)
{
    if (prio < -20)
    {
        prio = -20;
    }
    if (prio > 20)
    {
        prio = 20;
    }

    if (task == NULL)
    {
        current_task->prio_static = prio;
        current_task->prio_dynamic = prio;
        return;
    }

    task->prio_static = prio;
    task->prio_dynamic = prio;
}

int task_getprio(task_t *task)
{
    if (task == NULL)
    {
        return current_task->prio_static;
    }
    return task->prio_static;
}

task_t *scheduler()
{
    task_t *top_priority = ready_queue;
    task_t *initial = ready_queue;
    task_t *cursor = ready_queue;

    if (ready_queue == NULL)
    {
        return NULL;
    }

    do
    {
        // Compares dynamic priority
        if (cursor->prio_dynamic <= top_priority->prio_dynamic)
        {
            top_priority = cursor;
        }
        cursor = cursor->next;
    } while (cursor != initial);

    // Age not-selected tasks
    cursor = ready_queue;
    do
    {
        if (cursor != top_priority)
        {
            if (cursor->prio_dynamic > -20)
            {
                cursor->prio_dynamic -= SCHEDULER_AGING_ALPHA;
            }
        }
        cursor = cursor->next;
    } while (cursor != initial);

    top_priority->prio_dynamic = top_priority->prio_static; // Reset dynamic priority
    return top_priority;
}

void dispatcher()
{
    int ready_task_count = queue_size((queue_t *)ready_queue);
    while (ready_task_count > 0)
    {
        // queue_print("Ready queue", (queue_t *)ready_queue, print_task);
        task_t *next = scheduler();

        if (next == NULL)
        {
            break;
        }

        queue_remove((queue_t **)&ready_queue, (queue_t *)next);
        next->state = RUNNING;
        task_switch(next);

        // After a yield...
        switch (next->state)
        {
        case READY:
            queue_append((queue_t **)&ready_queue, (queue_t *)next);
        case TERMINATED:
            break;
        default:
            break;
        }
    }

    task_exit(0);
}