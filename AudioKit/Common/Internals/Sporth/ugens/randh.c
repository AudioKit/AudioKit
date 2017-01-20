#include "plumber.h"

int sporth_randh(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT min;
    SPFLOAT max;
    sp_randh *randh;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "randh: Creating\n");
#endif

            sp_randh_create(&randh);
            plumber_add_ugen(pd, SPORTH_RANDH, randh);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for randh\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            freq = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "randh: Initialising\n");
#endif

            freq = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            randh = pd->last->ud;
            sp_randh_init(pd->sp, randh);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            freq = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            randh = pd->last->ud;
            randh->freq = freq;
            randh->min = min;
            randh->max = max;
            sp_randh_compute(pd->sp, randh, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            randh = pd->last->ud;
            sp_randh_destroy(&randh);
            break;
        default:
            fprintf(stderr, "randh: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
