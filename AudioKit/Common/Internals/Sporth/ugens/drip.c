#include "plumber.h"

int sporth_drip(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT dettack;
    SPFLOAT num_tubes;
    SPFLOAT amp;
    SPFLOAT damp;
    SPFLOAT shake_max;
    SPFLOAT freq;
    SPFLOAT freq1;
    SPFLOAT freq2;
    sp_drip *drip;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "drip: Creating\n");
#endif

            sp_drip_create(&drip);
            plumber_add_ugen(pd, SPORTH_DRIP, drip);
            if(sporth_check_args(stack, "fffffffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for drip\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "drip: Initialising\n");
#endif

            dettack = sporth_stack_pop_float(stack);
            freq2 = sporth_stack_pop_float(stack);
            freq1 = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            shake_max = sporth_stack_pop_float(stack);
            damp = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            num_tubes = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            drip = pd->last->ud;
            sp_drip_init(pd->sp, drip, dettack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            dettack = sporth_stack_pop_float(stack);
            freq2 = sporth_stack_pop_float(stack);
            freq1 = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            shake_max = sporth_stack_pop_float(stack);
            damp = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            num_tubes = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            drip = pd->last->ud;
            drip->num_tubes = num_tubes;
            drip->amp = amp;
            drip->damp = damp;
            drip->shake_max = shake_max;
            drip->freq = freq;
            drip->freq1 = freq1;
            drip->freq2 = freq2;
            sp_drip_compute(pd->sp, drip, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            drip = pd->last->ud;
            sp_drip_destroy(&drip);
            break;
        default:
            plumber_print(pd, "drip: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
