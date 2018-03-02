#include "plumber.h"

int sporth_blsquare(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    SPFLOAT width;
    sp_blsquare *blsquare;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "blsquare: Creating\n");
#endif

            sp_blsquare_create(&blsquare);
            plumber_add_ugen(pd, SPORTH_SQUARE, blsquare);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for blsquare\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            width = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "blsquare: Initialising\n");
#endif

            width = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            blsquare = pd->last->ud;
            sp_blsquare_init(pd->sp, blsquare);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            width = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            blsquare = pd->last->ud;
            *blsquare->freq = freq;
            *blsquare->amp = amp;
            *blsquare->width = width;
            sp_blsquare_compute(pd->sp, blsquare, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            blsquare = pd->last->ud;
            sp_blsquare_destroy(&blsquare);
            break;
        default:
            plumber_print(pd, "blsquare: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
