#include "plumber.h"

int sporth_butbp(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT freq;
    SPFLOAT bw;
    sp_butbp *butbp;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "butbp: Creating\n");
#endif

            sp_butbp_create(&butbp);
            plumber_add_ugen(pd, SPORTH_BUTBP, butbp);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for butbp\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "butbp: Initialising\n");
#endif

            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            butbp = pd->last->ud;
            sp_butbp_init(pd->sp, butbp);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            butbp = pd->last->ud;
            butbp->freq = freq;
            butbp->bw = bw;
            sp_butbp_compute(pd->sp, butbp, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            butbp = pd->last->ud;
            sp_butbp_destroy(&butbp);
            break;
        default:
            fprintf(stderr, "butbp: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
