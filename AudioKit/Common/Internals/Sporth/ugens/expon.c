#include "plumber.h"

int sporth_expon(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT a;
    SPFLOAT dur;
    SPFLOAT b;
    sp_expon *expon;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "expon: Creating\n");
#endif

            sp_expon_create(&expon);
            plumber_add_ugen(pd, SPORTH_EXPON, expon);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for expon\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "expon: Initialising\n");
#endif

            b = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            a = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            expon = pd->last->ud;
            sp_expon_init(pd->sp, expon);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            b = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            a = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            expon = pd->last->ud;
            expon->a = a;
            expon->dur = dur;
            expon->b = b;
            sp_expon_compute(pd->sp, expon, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            expon = pd->last->ud;
            sp_expon_destroy(&expon);
            break;
        default:
            fprintf(stderr, "expon: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
