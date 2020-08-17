#include "plumber.h"

int sporth_tgate(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trigger;
    SPFLOAT gate;
    SPFLOAT time;
    sp_tgate *tgate;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tgate: Creating\n");
#endif

            sp_tgate_create(&tgate);
            plumber_add_ugen(pd, SPORTH_TGATE, tgate);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for tgate\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            time = sporth_stack_pop_float(stack);
            trigger = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tgate: Initialising\n");
#endif

            time = sporth_stack_pop_float(stack);
            trigger = sporth_stack_pop_float(stack);
            tgate = pd->last->ud;
            sp_tgate_init(pd->sp, tgate);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            time = sporth_stack_pop_float(stack);
            trigger = sporth_stack_pop_float(stack);
            tgate = pd->last->ud;
            tgate->time = time;
            sp_tgate_compute(pd->sp, tgate, &trigger, &gate);
            sporth_stack_push_float(stack, gate);
            break;
        case PLUMBER_DESTROY:
            tgate = pd->last->ud;
            sp_tgate_destroy(&tgate);
            break;
        default:
            plumber_print(pd, "tgate: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
