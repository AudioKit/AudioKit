#include "plumber.h"

int sporth_clock(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT bpm;
    SPFLOAT subdiv;
    sp_clock *clock;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "clock: Creating\n");
#endif

            sp_clock_create(&clock);
            plumber_add_ugen(pd, SPORTH_CLOCK, clock);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for clock\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            subdiv = sporth_stack_pop_float(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "clock: Initialising\n");
#endif

            subdiv = sporth_stack_pop_float(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            clock = pd->last->ud;
            sp_clock_init(pd->sp, clock);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            subdiv = sporth_stack_pop_float(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            clock = pd->last->ud;
            clock->bpm = bpm;
            clock->subdiv = subdiv;
            sp_clock_compute(pd->sp, clock, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            clock = pd->last->ud;
            sp_clock_destroy(&clock);
            break;
        default:
            plumber_print(pd, "clock: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
