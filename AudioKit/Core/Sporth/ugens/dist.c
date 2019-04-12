#include "plumber.h"

int sporth_dist(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT pregain;
    SPFLOAT postgain;
    SPFLOAT shape1;
    SPFLOAT shape2;
    sp_dist *dist;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "dist: Creating\n");
#endif

            sp_dist_create(&dist);
            plumber_add_ugen(pd, SPORTH_DIST, dist);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for dist\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            shape2 = sporth_stack_pop_float(stack);
            shape1 = sporth_stack_pop_float(stack);
            postgain = sporth_stack_pop_float(stack);
            pregain = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "dist: Initialising\n");
#endif
            shape2 = sporth_stack_pop_float(stack);
            shape1 = sporth_stack_pop_float(stack);
            postgain = sporth_stack_pop_float(stack);
            pregain = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            dist = pd->last->ud;
            sp_dist_init(pd->sp, dist);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            shape2 = sporth_stack_pop_float(stack);
            shape1 = sporth_stack_pop_float(stack);
            postgain = sporth_stack_pop_float(stack);
            pregain = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            dist = pd->last->ud;
            dist->pregain = pregain;
            dist->postgain = postgain;
            dist->shape1 = shape1;
            dist->shape2 = shape2;
            sp_dist_compute(pd->sp, dist, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            dist = pd->last->ud;
            sp_dist_destroy(&dist);
            break;
        default:
            plumber_print(pd, "dist: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
