#include "plumber.h"

int sporth_comb(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT looptime;
    SPFLOAT revtime;
    sp_comb *comb;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "comb: Creating\n");
#endif

            sp_comb_create(&comb);
            plumber_add_ugen(pd, SPORTH_COMB, comb);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for comb\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            looptime = sporth_stack_pop_float(stack);
            revtime = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "comb: Initialising\n");
#endif

            looptime = sporth_stack_pop_float(stack);
            revtime = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            comb = pd->last->ud;
            sp_comb_init(pd->sp, comb, looptime);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            looptime = sporth_stack_pop_float(stack);
            revtime = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            comb = pd->last->ud;
            comb->revtime = revtime;
            sp_comb_compute(pd->sp, comb, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            comb = pd->last->ud;
            sp_comb_destroy(&comb);
            break;
        default:
            plumber_print(pd, "comb: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
