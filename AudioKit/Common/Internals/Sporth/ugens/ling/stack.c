#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "sporth.h"
#include "ling.h"

int ling_stack_push(ling_stack *stack, uint32_t val)
{
    if(stack->error > 0) return LING_NOTOK;

    if(stack->pos <= 32) {
        stack->pos++;
        stack->stack[stack->pos - 1]= val;
        return LING_OK;
    } else {
        fprintf(stderr, "Stack limit of %d reached, cannot push float value.\n", stack->pos);
        stack->error++;
        return LING_NOTOK;
    }
    return LING_OK;
}

uint32_t ling_stack_pop(ling_stack *stack)
{
    if(stack->error > 0) return 0;

    uint32_t val;

    if(stack->pos == 0) {
       fprintf(stderr, "Ling: stack is empty.\n");
       stack->error++;
       return LING_NOTOK;
    }
    val = stack->stack[stack->pos - 1];

    stack->pos--;
    return val;
}

int ling_stack_init(ling_stack *stack)
{
    stack->pos = 0;
    stack->error = 0;
    return LING_OK;
}
