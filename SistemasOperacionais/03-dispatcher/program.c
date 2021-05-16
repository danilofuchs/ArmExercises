// PingPongOS - PingPong Operating System
// Prof. Carlos A. Maziero, DINF UFPR
// Versão 1.1 -- Julho de 2016

// Teste do task dispatcher e escalonador FCFS

#include <stdio.h>
#include <stdlib.h>
#include "ppos.h"
#include "utils/uartstdio.h"

task_t Pang, Peng, Ping, Pong, Pung;

// corpo das threads
void Body(void *arg)
{
    int i;

    UARTprintf("%s: inicio\n", (char *)arg);
    for (i = 0; i < 5; i++)
    {
        UARTprintf("%s: %d\n", (char *)arg, i);
        task_yield();
    }
    UARTprintf("%s: fim\n", (char *)arg);
    task_exit(0);
}

void program()
{
    UARTprintf("main: inicio\n");

    ppos_init();

    task_create(&Pang, Body, "    Pang");
    task_create(&Peng, Body, "        Peng");
    task_create(&Ping, Body, "            Ping");
    task_create(&Pong, Body, "                Pong");
    task_create(&Pung, Body, "                    Pung");

    task_yield();

    UARTprintf("main: fim\n");
}
