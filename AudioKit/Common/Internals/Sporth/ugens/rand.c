#include <stdlib.h>
#include "plumber.h"

int sporth_rand(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT min;
    SPFLOAT max;
    SPFLOAT *val;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "trand: Creating\n");
#endif
            val = malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_RAND, val);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for rand\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            *val = min + ((SPFLOAT)sp_rand(pd->sp) / SP_RANDMAX) * (max - min);
            sporth_stack_push_float(stack, *val);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "rand: Initialising\n");
#endif
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            val = pd->last->ud;
            sporth_stack_push_float(stack, *val);
            break;
        case PLUMBER_COMPUTE:
            val = pd->last->ud;
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, *val);
            break;
        case PLUMBER_DESTROY:
            val = pd->last->ud;
            free(val);
            break;
        default:
            fprintf(stderr, "rand: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
