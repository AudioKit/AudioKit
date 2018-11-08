#include "plumber.h"

int sporth_saturator(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT drive;
    SPFLOAT dcoffset;
    sp_saturator *saturator;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "saturator: Creating\n");
#endif

            sp_saturator_create(&saturator);
            plumber_add_ugen(pd, SPORTH_SATURATOR, saturator);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for saturator\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            dcoffset = sporth_stack_pop_float(stack);
            drive = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "saturator: Initialising\n");
#endif

            dcoffset = sporth_stack_pop_float(stack);
            drive = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            saturator = pd->last->ud;
            sp_saturator_init(pd->sp, saturator);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            dcoffset = sporth_stack_pop_float(stack);
            drive = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            saturator = pd->last->ud;
            saturator->drive = drive;
            saturator->dcoffset = dcoffset;
            sp_saturator_compute(pd->sp, saturator, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            saturator = pd->last->ud;
            sp_saturator_destroy(&saturator);
            break;
        default:
            plumber_print(pd, "saturator: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
