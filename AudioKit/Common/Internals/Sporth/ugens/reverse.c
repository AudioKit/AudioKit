#include "plumber.h"

int sporth_reverse(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT delay;
    sp_reverse *reverse;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "reverse: Creating\n");
#endif

            sp_reverse_create(&reverse);
            plumber_add_ugen(pd, SPORTH_REVERSE, reverse);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for reverse\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            delay = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "reverse: Initialising\n");
#endif
            delay = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            reverse = pd->last->ud;
            sp_reverse_init(pd->sp, reverse, delay);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            delay = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            reverse = pd->last->ud;
            sp_reverse_compute(pd->sp, reverse, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            reverse = pd->last->ud;
            sp_reverse_destroy(&reverse);
            break;
        default:
            fprintf(stderr, "reverse: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
