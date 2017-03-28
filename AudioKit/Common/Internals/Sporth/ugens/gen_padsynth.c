#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

int sporth_gen_padsynth(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sp_ftbl *ft, *amps;
    char *ftname, *ampname;
    uint32_t size;
    SPFLOAT freq, bw;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_GEN_PADSYNTH, NULL);
            if(sporth_check_args(stack, "sfffs") != SPORTH_OK) {
                plumber_print(pd,"Padsynth: not enough arguments for gen_padsynth\n");
                return PLUMBER_NOTOK;
            }
            ampname = sporth_stack_pop_string(stack);
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            size = (uint32_t)sporth_stack_pop_float(stack);
            ftname = sporth_stack_pop_string(stack);

            if(plumber_ftmap_search(pd, ampname, &amps) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            

            sp_ftbl_create(pd->sp, &ft, size);

#ifdef DEBUG_MODE
            plumber_print(pd,"Running padsynth function\n");
#endif
            sp_gen_padsynth(pd->sp, ft, amps, freq, bw);

            plumber_ftmap_add(pd, ftname, ft);
            break;

        case PLUMBER_INIT:
            ampname = sporth_stack_pop_string(stack);
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            size = (uint32_t)sporth_stack_pop_float(stack);
            ftname = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
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
