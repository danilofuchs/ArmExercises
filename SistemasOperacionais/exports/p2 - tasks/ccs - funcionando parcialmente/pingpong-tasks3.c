// PingPongOS - PingPong Operating System
// Prof. Carlos A. Maziero, DINF UFPR
// Versão 1.1 -- Julho de 2016

// Teste da gestão básica de tarefas

#include <stdio.h>
#include <stdlib.h>
#include "ppos.h"
#include "utils/uartstdio.h"

#define MAXTASK 10

task_t task;

// corpo das threads
void BodyTask3(void *arg)
{
   UARTprintf("Estou na tarefa %5d\n", task_id());
   task_exit(0);
}

void task3()
{
   int i;

   UARTprintf("main: inicio\n");

   ppos_init();

   // cria MAXTASK tarefas, ativando cada uma apos sua criacao
   for (i = 0; i < MAXTASK; i++)
   {
      task_create(&task, BodyTask3, NULL);
      task_switch(&task);
   }

   UARTprintf("main: fim\n");
}
