#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

int sporth_gen_vals(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sp_ftbl *ft;
    char *str, *args;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_GEN_VALS, NULL);

            if(sporth_check_args(stack, "ss") != SPORTH_OK) {
                plumber_print(pd,"Init: not enough arguments for gen_vals\n");
                return PLUMBER_NOTOK;
            }

            args = sporth_stack_pop_string(stack);
            str = sporth_stack_pop_string(stack);

#ifdef DEBUG_MODE
            plumber_print(pd,"Creating value table %s\n", str + 1);
#endif
            sp_ftbl_create(pd->sp, &ft, 1);

#ifdef DEBUG_MODE
            plumber_print(pd,"Running gen_val function\n");
#endif
            sp_gen_vals(pd->sp, ft, args);

#ifdef DEBUG_MODE
            plumber_print(pd,"Adding ftable\n");
#endif

            plumber_ftmap_add(pd, str, ft);

            break;

        case PLUMBER_INIT:
            args = sporth_stack_pop_string(stack);
            str = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
          plumber_print(pd,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
