#include <stdio.h>
#include <stdarg.h>
#include "queue.h"
#include "debug.h"

void queue_append(queue_t **queue, queue_t *element)
{
    debug_fn_start("queue_append");
    debug_fn_step("queue: %p", *queue);
    debug_fn_step("element: %p", element);

    if (element->next != NULL || element->prev != NULL)
    {
        printf("### ERROR: Element already present in another queue\n");
        return;
    }

    if (*queue == NULL)
    {
        // Criar uma fila nova, apontando o elemento para si mesmo
        element->next = element;
        element->prev = element;
        // Primeiro elemento é ele mesmo
        *queue = element;
    }
    else
    {
        // Adicionando a uma fila existente:

        // next: aponta para o primeiro da fila
        element->next = (*queue);
        // prev: aponta para o último da fila (prev do primeiro atual)
        element->prev = (*queue)->prev;
        // Último antigo agora aponta para o novo elemento
        (*queue)->prev->next = element;
        // Último elemento da fila é o novo elemento
        (*queue)->prev = element;
    }
    debug_fn_return(NULL);
}

queue_t *queue_remove(queue_t **queue, queue_t *element)
{
    debug_fn_start("queue_remove");
    debug_fn_step("element: %p", element);
    if (!queue)
    {
        printf("### ERROR: Cannot remove element from empty queue\n");
        debug_fn_return("NULL_QUEUE");
        return NULL;
    }
    if (!element)
    {
        printf("### ERROR: Element should be defined\n");
        debug_fn_return("NULL_ELEMENT");
        return NULL;
    }

    // Encontrar elemento na fila
    int element_is_in_queue = 0;
    queue_t *current_element = *queue;
    while (1)
    {
        if (current_element == element)
        {
            // Encontrou
            element_is_in_queue = 1;
            break;
        }

        current_element = current_element->next;
        if (current_element == *queue)
        {
            // Chegou ao final da busca (voltou ao primeiro)
            element_is_in_queue = 0;
            break;
        }
    }

    if (!element_is_in_queue)
    {
        printf("### ERROR: Cannot remove element which is not in the queue\n");
        debug_fn_return("ELEMENT_NOT_FOUND");
        return NULL;
    }

    if (element == element->next)
    {
        // Somente um elemento.
        // Devemos esvaziar a fila e as conexões do elemento
        *queue = NULL;
        element->prev = NULL;
        element->next = NULL;
        debug_fn_return("%p", element);
        return element;
    }

    // Anterior deve apontar para o próximo
    element->prev->next = element->next;

    // Próximo deve apontar para o anterior
    element->next->prev = element->prev;

    if (element == *queue)
    {
        // Se estamos removendo o primeiro, temos que mover o ponteiro inicial
        *queue = element->next;
    }

    // Limpar o elemento das suas conexões
    element->prev = NULL;
    element->next = NULL;

    debug_fn_return("%p", element);
    return element;
}

int queue_size(queue_t *queue)
{
    debug_fn_start("queue_size");
    debug_fn_step("queue: %p", queue);
    if (!queue)
    {
        debug_fn_return("%d", 0);
        return 0;
    }
    debug_fn_step("needle: %p", queue);
    debug_fn_step("next: %p", queue->next);
    debug_fn_step("prev: %p", queue->prev);

    int size = 1;
    queue_t *first_element = queue;
    queue_t *current = first_element->next;

    while (current != first_element)
    {
        current = current->next;
        size++;
    };

    debug_fn_return("%d", size);
    return size;
}

void queue_print(char *name, queue_t *queue, void print_elem(void *))
{
    if (!queue)
    {
        printf("%s: []\n", name);
        return;
    }
    queue_t *first_element = queue;
    queue_t *current = first_element;
    printf("%s: [", name);

    do
    {
        print_elem(current);
        if (current->next != first_element)
        {
            printf(" ");
        }
        current = current->next;
    } while (current != first_element);

    printf("]\n");
}