#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_gen_file(sporth_stack *stack, void *ud)
{
#ifndef NO_LIBSNDFILE
    plumber_data *pd = ud;

    sp_ftbl *ft;
    const char *str;
    const char *filename;
    int size;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_GEN_FILE, NULL);
            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
                plumber_print(pd, "Init: not enough arguments for gen_file\n");
                return PLUMBER_NOTOK;
            }

            filename = sporth_stack_pop_string(stack);
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
            sp_ftbl_create(pd->sp, &ft, size);
            if(sp_gen_file(pd->sp, ft, filename) == SP_NOT_OK) {
                plumber_print(pd, "There was an issue creating the ftable \"%s\".\n", str);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            plumber_ftmap_add(pd, str, ft);
            break;

        case PLUMBER_INIT:
            filename = sporth_stack_pop_string(stack);
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
#else
    return PLUMBER_NOTOK;
#endif
}
