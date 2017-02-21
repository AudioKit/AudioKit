#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_scrambler(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sp_ftbl *ft_s, *ft_d;
    char *src, *dst;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SCRAMBLER, NULL);
            if(sporth_check_args(stack, "ss") != SPORTH_OK) {
                plumber_print(pd, "Init: not enough arguments for gen_line\n");
                return PLUMBER_NOTOK;
            }

            src = sporth_stack_pop_string(stack);
            dst = sporth_stack_pop_string(stack);

            if(plumber_ftmap_search(pd, src, &ft_s) != PLUMBER_OK) {
                plumber_print(pd, 
                    "scrambler: could not find ftable %s",
                    src);
            }

            sp_gen_scrambler(pd->sp, ft_s, &ft_d);
            plumber_ftmap_add(pd, dst, ft_d);
            break;

        case PLUMBER_INIT:
            sporth_stack_pop_string(stack);
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           break;
    }
    return PLUMBER_OK;
}
