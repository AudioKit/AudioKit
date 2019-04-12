#include "plumber.h"

int sporth_waveset(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT ilen;
    SPFLOAT rep;
    sp_waveset *waveset;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "waveset: Creating\n");
#endif

            sp_waveset_create(&waveset);
            plumber_add_ugen(pd, SPORTH_WAVESET, waveset);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for waveset\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ilen = sporth_stack_pop_float(stack);
            rep = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "waveset: Initialising\n");
#endif

            ilen = sporth_stack_pop_float(stack);
            rep = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            waveset = pd->last->ud;
            sp_waveset_init(pd->sp, waveset, ilen);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            ilen = sporth_stack_pop_float(stack);
            rep = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            waveset = pd->last->ud;
            waveset->rep = rep;
            sp_waveset_compute(pd->sp, waveset, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            waveset = pd->last->ud;
            sp_waveset_destroy(&waveset);
            break;
        default:
            plumber_print(pd, "waveset: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
