// PingPongOS - PingPong Operating System
// Prof. Carlos A. Maziero, DINF UFPR
// Versão 1.1 -- Julho de 2016

// Teste da gestão básica de tarefas

#include <stdio.h>
#include <stdlib.h>
#include "ppos.h"
#include "libraries/debug.h"
#include "utils/uartstdio.h"

task_t MainTask, Ping, Pong;

// corpo da thread Ping
void BodyPing(void *arg)
{
    int i;
    char *name = (char *)arg;

    UARTprintf("%s: inicio\n", name);
    for (i = 0; i < 4; i++)
    {
        UARTprintf("%s: %d\n", name, i);
        task_switch(&Pong);
    }
    UARTprintf("%s: fim\n", name);
    task_exit(0);
}

// corpo da thread Pong
void BodyPong(void *arg)
{
    int i;
    char *name = (char *)arg;

    UARTprintf("%s: inicio\n", name);
    for (i = 0; i < 4; i++)
    {
        UARTprintf("%s: %d\n", name, i);
        task_switch(&Ping);
    }
    UARTprintf("%s: fim\n", name);
    task_exit(0);
}

int task1(void *arg)
{
    UARTprintf("main: inicio\n");

    ppos_init();

    task_create(&Ping, BodyPing, "    Ping");
    task_create(&Pong, BodyPong, "        Pong");

    task_switch(&Ping);
    task_switch(&Pong);

    UARTprintf("main: fim\n");

    exit(0);
}
