#include "plumber.h"

int sporth_scale2(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT inmin;
    SPFLOAT inmax;
    SPFLOAT outmin;
    SPFLOAT outmax;
    sp_scale *scale;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "scale2: Creating\n");
#endif

            sp_scale_create(&scale);
            plumber_add_module(pd, SPORTH_SCALE2, scale);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "scale2: Initialising\n");
#endif

            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for scale2\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            outmax = sporth_stack_pop_float(stack);
            outmin = sporth_stack_pop_float(stack);
            inmax = sporth_stack_pop_float(stack);
            inmin = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            scale = pd->last->ud;
            sp_scale_init(pd->sp, scale);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for scale2\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            outmax = sporth_stack_pop_float(stack);
            outmin = sporth_stack_pop_float(stack);
            inmax = sporth_stack_pop_float(stack);
            inmin = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            scale = pd->last->ud;
            scale->inmin  = inmin;
            scale->inmax  = inmax;
            scale->outmin = outmin;
            scale->outmax = outmax;
            sp_scale_compute(pd->sp, scale, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            scale = pd->last->ud;
            sp_scale_destroy(&scale);
            break;
        default:
            fprintf(stderr, "scale: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
