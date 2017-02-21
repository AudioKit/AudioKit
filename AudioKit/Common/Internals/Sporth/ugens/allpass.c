#include "plumber.h"

int sporth_allpass(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT looptime;
    SPFLOAT revtime;
    sp_allpass *allpass;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "allpass: Creating\n");
#endif

            sp_allpass_create(&allpass);
            plumber_add_ugen(pd, SPORTH_ALLPASS, allpass);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for allpass\n");
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
            plumber_print(pd, "allpass: Initialising\n");
#endif

            looptime = sporth_stack_pop_float(stack);
            revtime = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            allpass = pd->last->ud;
            sp_allpass_init(pd->sp, allpass, looptime);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            looptime = sporth_stack_pop_float(stack);
            revtime = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            allpass = pd->last->ud;
            allpass->revtime = revtime;
            sp_allpass_compute(pd->sp, allpass, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            allpass = pd->last->ud;
            sp_allpass_destroy(&allpass);
            break;
        default:
            plumber_print(pd, "allpass: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
