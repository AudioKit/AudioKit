#include "plumber.h"

int sporth_trand(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT min;
    SPFLOAT max;
    sp_trand *trand;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "trand: Creating\n");
#endif

            sp_trand_create(&trand);
            plumber_add_ugen(pd, SPORTH_TRAND, trand);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for trand\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "trand: Initialising\n");
#endif
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            trand = pd->last->ud;
            sp_trand_init(pd->sp, trand);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            trand = pd->last->ud;
            trand->min = min;
            trand->max = max;
            sp_trand_compute(pd->sp, trand, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            trand = pd->last->ud;
            sp_trand_destroy(&trand);
            break;
        default:
            fprintf(stderr, "trand: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
