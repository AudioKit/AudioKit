#include "plumber.h"

int sporth_maygate(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT prob;
    sp_maygate *maygate;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "maygate: Creating\n");
#endif

            sp_maygate_create(&maygate);
            plumber_add_ugen(pd, SPORTH_MAYGATE, maygate);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for maygate\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            prob = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "maygate: Initialising\n");
#endif

            prob = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            maygate = pd->last->ud;
            sp_maygate_init(pd->sp, maygate);
            maygate->mode = 0;
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            prob = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            maygate = pd->last->ud;
            maygate->prob = prob;
            sp_maygate_compute(pd->sp, maygate, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            maygate = pd->last->ud;
            sp_maygate_destroy(&maygate);
            break;
        default:
            plumber_print(pd, "maygate: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
