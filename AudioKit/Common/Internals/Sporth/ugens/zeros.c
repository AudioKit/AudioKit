#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_zeros(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    int size;
    sp_ftbl *ft;
    char *str;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_ZEROS, NULL);
            if(sporth_check_args(stack, "sf") != SPORTH_OK) {
                fprintf(stderr, "Init: not enough arguments for zeros\n");
                return PLUMBER_NOTOK;
            }
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
#ifdef DEBUG_MODE
            fprintf(stderr, "Zeros: creating table %s of size %d\n", str, size);
#endif
            sp_ftbl_create(pd->sp, &ft, size);
            plumber_ftmap_add(pd, str, ft);
            break;

        case PLUMBER_INIT:
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            size = (int)sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           fprintf(stderr, "Error: Unknown mode!\n");
           break;
    }
    return PLUMBER_OK;
}
