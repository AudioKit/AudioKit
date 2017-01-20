#include "plumber.h"

int sporth_moogladder(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT res;
    sp_moogladder *moogladder;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "moogladder: Creating\n");
#endif

            sp_moogladder_create(&moogladder);
            plumber_add_ugen(pd, SPORTH_MOOGLADDER, moogladder);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for moogladder\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            res = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "moogladder: Initialising\n");
#endif
            res = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            moogladder = pd->last->ud;
            sp_moogladder_init(pd->sp, moogladder);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            res = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            moogladder = pd->last->ud;
            moogladder->freq = freq;
            moogladder->res = res;
            sp_moogladder_compute(pd->sp, moogladder, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            moogladder = pd->last->ud;
            sp_moogladder_destroy(&moogladder);
            break;
        default:
            fprintf(stderr, "moogladder: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
