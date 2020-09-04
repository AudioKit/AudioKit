#include "plumber.h"

int sporth_blsaw(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    sp_blsaw *blsaw;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "blsaw: Creating\n");
#endif

            sp_blsaw_create(&blsaw);
            plumber_add_ugen(pd, SPORTH_SAW, blsaw);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for blsaw\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "blsaw: Initialising\n");
#endif
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            blsaw = pd->last->ud;
            sp_blsaw_init(pd->sp, blsaw);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            blsaw = pd->last->ud;
            *blsaw->freq = freq;
            *blsaw->amp = amp;
            sp_blsaw_compute(pd->sp, blsaw, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            blsaw = pd->last->ud;
            sp_blsaw_destroy(&blsaw);
            break;
        default:
            plumber_print(pd, "blsaw: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
