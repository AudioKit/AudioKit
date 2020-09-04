#include "plumber.h"

int sporth_timer(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT clock;
    SPFLOAT out;
    sp_timer *timer;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "timer: Creating\n");
#endif

            sp_timer_create(&timer);
            plumber_add_ugen(pd, SPORTH_TIMER, timer);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for timer\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            clock = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "timer: Initialising\n");
#endif

            clock = sporth_stack_pop_float(stack);
            timer = pd->last->ud;
            sp_timer_init(pd->sp, timer);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            clock = sporth_stack_pop_float(stack);
            timer = pd->last->ud;
            sp_timer_compute(pd->sp, timer, &clock, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            timer = pd->last->ud;
            sp_timer_destroy(&timer);
            break;
        default:
            plumber_print(pd, "timer: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
