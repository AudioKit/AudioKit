#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_say(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    const char *str;
    switch(pd->mode) {
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SAY, NULL);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd,"Say: not enough arguments.\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            plumber_print(pd, "%s\n", str);
            break;
        case PLUMBER_INIT:
            str = sporth_stack_pop_string(stack);
            break;
        case PLUMBER_COMPUTE:
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd, "print: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
