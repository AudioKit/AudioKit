#include "plumber.h"

int sporth_pshift(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT shift;
    SPFLOAT window;
    SPFLOAT xfade;
    sp_pshift *pshift;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "pshift: Creating\n");
#endif

            sp_pshift_create(&pshift);
            plumber_add_ugen(pd, SPORTH_PSHIFT, pshift);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for pshift\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            xfade = sporth_stack_pop_float(stack);
            window = sporth_stack_pop_float(stack);
            shift = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sp_pshift_init(pd->sp, pshift);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "pshift: Initialising\n");
#endif

            xfade = sporth_stack_pop_float(stack);
            window = sporth_stack_pop_float(stack);
            shift = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            xfade = sporth_stack_pop_float(stack);
            window = sporth_stack_pop_float(stack);
            shift = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            pshift = pd->last->ud;
            *pshift->shift = shift;
            *pshift->window = window;
            *pshift->xfade = xfade;
            sp_pshift_compute(pd->sp, pshift, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            pshift = pd->last->ud;
            sp_pshift_destroy(&pshift);
            break;
        default:
            fprintf(stderr, "pshift: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
