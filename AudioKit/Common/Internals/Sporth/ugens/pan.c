#include "plumber.h"

int sporth_pan2(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out_left;
    SPFLOAT out_right;
    SPFLOAT pan;
    sp_pan2 *pan2;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "pan2: Creating\n");
#endif

            sp_pan2_create(&pan2);
            plumber_add_ugen(pd, SPORTH_PAN, pan2);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for pan2\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            pan = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "pan2: Initialising\n");
#endif
            pan = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            pan2 = pd->last->ud;
            sp_pan2_init(pd->sp, pan2);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            pan = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            pan2 = pd->last->ud;
            pan2->pan = pan;
            sp_pan2_compute(pd->sp, pan2, &in, &out_left, &out_right);
            sporth_stack_push_float(stack, out_left);
            sporth_stack_push_float(stack, out_right);
            break;
        case PLUMBER_DESTROY:
            pan2 = pd->last->ud;
            sp_pan2_destroy(&pan2);
            break;
        default:
            fprintf(stderr, "pan2: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
