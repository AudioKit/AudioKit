#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_gen_sinesum(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    int size;
    sp_ftbl *ft;
    char *str;
    char *args;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_GEN_SINESUM, NULL);
            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
                fprintf(stderr, "Init: not enough arguments for gen_sinesum\n");
                return PLUMBER_NOTOK;
            }

            args = sporth_stack_pop_string(stack);
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
#ifdef DEBUG_MODE
            fprintf(stderr, "Creating sinesum table %s of size %d\n", str, size);
#endif
            sp_ftbl_create(pd->sp, &ft, size);
            if(sp_gen_sinesum(pd->sp, ft, args) == SP_NOT_OK) {
                fprintf(stderr, "There was an issue creating the sinesume ftable \"%s\".\n", str);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            plumber_ftmap_add(pd, str, ft);
            break;

        case PLUMBER_INIT:
            args = sporth_stack_pop_string(stack);
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            size = (int)sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
