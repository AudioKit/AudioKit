#include "plumber.h"

int sporth_buthp(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT freq;
    sp_buthp *buthp;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "buthp: Creating\n");
#endif

            sp_buthp_create(&buthp);
            plumber_add_ugen(pd, SPORTH_BUTHP, buthp);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for buthp\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "buthp: Initialising\n");
#endif
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            buthp = pd->last->ud;
            sp_buthp_init(pd->sp, buthp);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            buthp = pd->last->ud;
            buthp->freq = freq;
            sp_buthp_compute(pd->sp, buthp, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            buthp = pd->last->ud;
            sp_buthp_destroy(&buthp);
            break;
        default:
            plumber_print(pd, "buthp: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
