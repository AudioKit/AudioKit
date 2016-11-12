#include "plumber.h"

int sporth_incr(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT step;
    SPFLOAT min;
    SPFLOAT max;
    SPFLOAT val;
    sp_incr *incr;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "incr: Creating\n");
#endif

            sp_incr_create(&incr);
            plumber_add_ugen(pd, SPORTH_INCR, incr);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for incr\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            step = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "incr: Initialising\n");
#endif
            val = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            step = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            incr = pd->last->ud;
            sp_incr_init(pd->sp, incr, val);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            val = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            step = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            incr = pd->last->ud;
            incr->step = step;
            incr->min = min;
            incr->max = max;
            sp_incr_compute(pd->sp, incr, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            incr = pd->last->ud;
            sp_incr_destroy(&incr);
            break;
        default:
            fprintf(stderr, "incr: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
