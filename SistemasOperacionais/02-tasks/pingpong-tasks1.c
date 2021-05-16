// PingPongOS - PingPong Operating System
// Prof. Carlos A. Maziero, DINF UFPR
// Versão 1.1 -- Julho de 2016

// Teste da gestão básica de tarefas

#include "ppos.h"
#include "libraries/debug.h"
#include "utils/uartstdio.h"

task_t Ping, Pong;

// corpo da thread Ping
void BodyPing1(void *arg)
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
void BodyPong1(void *arg)
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

void task1()
{
    UARTprintf("MAIN: inicio\n");

    ppos_init();

    task_create(&Ping, BodyPing1, "    Ping");
    task_create(&Pong, BodyPong1, "        Pong");

    task_switch(&Ping);
    task_switch(&Pong);

    UARTprintf("MAIN: fim\n");
}
