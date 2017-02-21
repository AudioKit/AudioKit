#include "plumber.h"

int sporth_streson(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT freq;
    SPFLOAT fdbgain;
    sp_streson *streson;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "streson: Creating\n");
#endif

            sp_streson_create(&streson);
            plumber_add_ugen(pd, SPORTH_STRESON, streson);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for streson\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fdbgain = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "streson: Initialising\n");
#endif

            fdbgain = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            streson = pd->last->ud;
            sp_streson_init(pd->sp, streson);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            fdbgain = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            streson = pd->last->ud;
            streson->freq = freq;
            streson->fdbgain = fdbgain;
            sp_streson_compute(pd->sp, streson, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            streson = pd->last->ud;
            sp_streson_destroy(&streson);
            break;
        default:
            plumber_print(pd, "streson: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
