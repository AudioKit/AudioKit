#include "plumber.h"

int sporth_hilbert(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out1;
    SPFLOAT out2;
    sp_hilbert *hilbert;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "hilbert: Creating\n");
#endif

            sp_hilbert_create(&hilbert);
            plumber_add_ugen(pd, SPORTH_HILBERT, hilbert);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for hilbert\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "hilbert: Initialising\n");
#endif

            input = sporth_stack_pop_float(stack);
            hilbert = pd->last->ud;
            sp_hilbert_init(pd->sp, hilbert);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            input = sporth_stack_pop_float(stack);
            hilbert = pd->last->ud;
            sp_hilbert_compute(pd->sp, hilbert, &input, &out1, &out2);
            sporth_stack_push_float(stack, out1);
            sporth_stack_push_float(stack, out2);
            break;
        case PLUMBER_DESTROY:
            hilbert = pd->last->ud;
            sp_hilbert_destroy(&hilbert);
            break;
        default:
            fprintf(stderr, "hilbert: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
