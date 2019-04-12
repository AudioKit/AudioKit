#include "plumber.h"

int sporth_scale(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT min;
    SPFLOAT max;
    sp_scale *scale;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "scale: Creating\n");
#endif

            sp_scale_create(&scale);
            plumber_add_ugen(pd, SPORTH_SCALE, scale);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for scale\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "scale: Initialising\n");
#endif
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            scale = pd->last->ud;
            sp_scale_init(pd->sp, scale);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            scale = pd->last->ud;
            scale->min = min;
            scale->max = max;
            sp_scale_compute(pd->sp, scale, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            scale = pd->last->ud;
            sp_scale_destroy(&scale);
            break;
        default:
            plumber_print(pd, "scale: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
