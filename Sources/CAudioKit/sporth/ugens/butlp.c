#include "plumber.h"

int sporth_butlp(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT freq;
    sp_butlp *butlp;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "butlp: Creating\n");
#endif

            sp_butlp_create(&butlp);
            plumber_add_ugen(pd, SPORTH_BUTLP, butlp);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for butlp\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "butlp: Initialising\n");
#endif
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            butlp = pd->last->ud;
            sp_butlp_init(pd->sp, butlp);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            butlp = pd->last->ud;
            butlp->freq = freq;
            sp_butlp_compute(pd->sp, butlp, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            butlp = pd->last->ud;
            sp_butlp_destroy(&butlp);
            break;
        default:
            plumber_print(pd, "butlp: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
