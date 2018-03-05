#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

int sporth_gen_rand(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    uint32_t size;
    sp_ftbl *ft;
    const char *str, *args;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_GEN_RAND, NULL);

            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
               plumber_print(pd,
                       "gen_rand: not enough arguments for gen_rand\n");
                return PLUMBER_NOTOK;
            }

            args = sporth_stack_pop_string(stack);
            size = (uint32_t)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);

            sp_ftbl_create(pd->sp, &ft, size);

            sp_gen_rand(pd->sp, ft, args);

            plumber_ftmap_add(pd, str, ft);
            break;

        case PLUMBER_INIT:
            sporth_stack_pop_string(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
          plumber_print(pd,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
