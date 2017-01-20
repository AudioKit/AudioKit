#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_eval(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    plumbing *pipes;

    char *str;
    int rc = PLUMBER_OK;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_EVAL, NULL);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                fprintf(stderr, "Not enough arguments for eval.\n");
                return PLUMBER_NOTOK;
            }

            str = sporth_stack_pop_string(stack);
            pipes = plumber_get_pipes(pd);
            rc = plumbing_parse_string(pd, pipes, str);
            return rc;

        case PLUMBER_INIT:
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
