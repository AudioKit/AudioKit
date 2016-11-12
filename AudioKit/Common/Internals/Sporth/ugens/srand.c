#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_srand(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    uint32_t seed = 0;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_SRAND, NULL);

            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr, "rseed: not enough arguments\n");
                return PLUMBER_NOTOK;
            }
#ifdef DEBUG_MODE
            fprintf(stderr, "Setting seed to %d\n");
#endif
            seed = (uint32_t)sporth_stack_pop_float(stack);
            fprintf(stderr, "seed: %u\n", seed);
            sp_srand(pd->sp, seed);
            pd->seed = seed;

            break;

        case PLUMBER_INIT:
            seed = (uint32_t)sporth_stack_pop_float(stack);
            break;

        case PLUMBER_COMPUTE:
            seed = (uint32_t)sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           break;
    }
    return PLUMBER_OK;
}
