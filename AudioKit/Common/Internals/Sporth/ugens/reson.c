#include "plumber.h"

int sporth_reson(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT freq;
    SPFLOAT bw;
    sp_reson *reson;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "reson: Creating\n");
#endif

            sp_reson_create(&reson);
            plumber_add_ugen(pd, SPORTH_RESON, reson);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for reson\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "reson: Initialising\n");
#endif

            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            reson = pd->last->ud;
            sp_reson_init(pd->sp, reson);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            reson = pd->last->ud;
            reson->freq = freq;
            reson->bw = bw;
            sp_reson_compute(pd->sp, reson, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            reson = pd->last->ud;
            sp_reson_destroy(&reson);
            break;
        default:
            fprintf(stderr, "reson: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
