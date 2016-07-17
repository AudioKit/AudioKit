#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "h/sporth.h"

#ifdef DEBUG_MODE
static void print_guts(sporth_stack *stack) 
{
    int i;
    fprintf(stderr, "Dying stack contents:\n");
    for(i = 0; i < stack->pos; i++) {
        fprintf(stderr, "\t %d: ", i);
        switch(stack->stack[i].type) {
            case SPORTH_FLOAT:
                fprintf(stderr, "%g\n", stack->stack[i].fval);
                break;
            case SPORTH_STRING:
                fprintf(stderr, "%s\n", stack->stack[i].sval);
                break;
            default:
                fprintf(stderr, "General type of %d\n", stack->stack[i].type);
                break;
        }
    }
}
#endif

int sporth_stack_push_float(sporth_stack *stack, float val)
{
    if(stack->error > 0) return SPORTH_NOTOK;

    if(stack->pos <= SPORTH_STACK_SIZE) {
        //printf("Pushing value %g.\n", val);
        stack->pos++;
        stack->stack[stack->pos - 1].fval = val;
        stack->stack[stack->pos - 1].type = SPORTH_FLOAT;
        return SPORTH_OK;
    } else {
        fprintf(stderr, "Stack limit of %d reached, cannot push float value.\n", stack->pos);
        stack->error++;
#ifdef DEBUG_MODE
        print_guts(stack);
#endif
        return SPORTH_NOTOK;
    }
    return SPORTH_OK;
}

int sporth_stack_push_string(sporth_stack *stack, const char *str)
{
    if(stack->error > 0) return SPORTH_NOTOK;

    sporth_stack_val *pstack;
    if(stack->pos <= SPORTH_STACK_SIZE) {
        stack->pos++;
        pstack = &stack->stack[stack->pos - 1];
        strncpy(pstack->sval, str, SPORTH_MAXCHAR);
        pstack->fval = strlen(str);
        pstack->type = SPORTH_STRING;
        return SPORTH_OK;
    } else {
        fprintf(stderr, "Stack limit of %d reached, cannot push float value.\n", stack->pos);
        stack->error++;
#ifdef DEBUG_MODE
        print_guts(stack);
#endif
        return SPORTH_NOTOK;
    }
    return SPORTH_OK;
}

float sporth_stack_pop_float(sporth_stack *stack)
{
    if(stack->error > 0) return 0;

    sporth_stack_val *pstack;

    if(stack->pos == 0) {
       fprintf(stderr, "Stack is empty.\n");
       stack->error++;
       return SPORTH_NOTOK;
    }
    pstack = &stack->stack[stack->pos - 1];

    if(pstack->type != SPORTH_FLOAT) {
        fprintf(stderr, "Value is not a float.\n");
        stack->error++;
        return SPORTH_NOTOK;
    }

    stack->pos--;
    return pstack->fval;
}

char * sporth_stack_pop_string(sporth_stack *stack)
{
    if(stack->error > 0) return NULL;

    char *str;
    sporth_stack_val *pstack;

    if(stack->pos == 0) {
       fprintf(stderr, "Stack is empty.\n");
       stack->error++;
       return NULL;
    }
    pstack = &stack->stack[stack->pos - 1];

    if(pstack->type != SPORTH_STRING) {
        fprintf(stderr, "Value is not a string.\n");
        stack->error++;
        return NULL;
    }

    str = malloc(sizeof(char) * (pstack->fval + 1));
    strcpy(str, pstack->sval);
    stack->pos--;
    return str;
}

int sporth_stack_init(sporth_stack *stack)
{
    stack->pos = 0;
    stack->error = 0;
    return SPORTH_OK;
}
