// PingPongOS - PingPong Operating System
// Prof. Carlos A. Maziero, DINF UFPR
// Versão 1.1 -- Julho de 2016

// Teste da gestão básica de tarefas

#include <stdio.h>
#include <stdlib.h>
#include "ppos.h"
#include "utils/uartstdio.h"

#define MAXTASK 10

task_t task[MAXTASK + 1];

// corpo das threads
void BodyTask2(void *arg)
{
    int next;

    UARTprintf("Iniciei  tarefa %5d\n", task_id());

    // passa o controle para a proxima tarefa
    next = (task_id() < MAXTASK) ? task_id() + 1 : 1;
    task_switch(&task[next]);

    UARTprintf("Encerrei tarefa %5d\n", task_id());

    task_exit(0);
}

void task2()
{
    int i;

    UARTprintf("main: inicio\n");

    ppos_init();

    // cria MAXTASK tarefas
    for (i = 1; i <= MAXTASK; i++)
        task_create(&task[i], BodyTask2, NULL);

    // passa o controle para cada uma delas em sequencia
    for (i = 1; i <= MAXTASK; i++)
        task_switch(&task[i]);

    UARTprintf("main: fim\n");
}
