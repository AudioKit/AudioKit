#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_say(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    char *str = NULL;
    switch(pd->mode) {
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SAY, NULL);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                fprintf(stderr,"Say: not enough arguments.\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            fprintf(stderr, "%s\n", str);
            break;
        case PLUMBER_INIT:
            str = sporth_stack_pop_string(stack);
            break;
        case PLUMBER_COMPUTE:
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            fprintf(stderr, "print: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
