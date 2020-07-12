#include <stdio.h>
#include <stdlib.h>
#include "plumber.h"

typedef struct {
    SPFLOAT trigger;
    SPFLOAT excite;
    SPFLOAT ifreq;
    sp_pluck *pluck;
    sp_ftbl *ft;
    sp_osc *exc;
} sporth_pluck_d;


int sporth_pluck(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sp_pluck *pluck;
    SPFLOAT freq = 0;
    SPFLOAT amp = 0;
    SPFLOAT trig = 0;
    SPFLOAT ifreq = 0;
    SPFLOAT out = 0;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "pluck: Creating\n");
#endif
            sp_pluck_create(&pluck);
            plumber_add_ugen(pd, SPORTH_PLUCK, pluck);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for pluck\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            ifreq = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "pluck: Initialising\n");
#endif

            pluck = pd->last->ud;

            ifreq = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            sp_pluck_init(pd->sp, pluck, ifreq);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            pluck = pd->last->ud;

            ifreq = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            pluck->freq = freq;
            pluck->amp = amp;

            sp_pluck_compute(pd->sp, pluck, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            pluck = pd->last->ud;
            sp_pluck_destroy(&pluck);
            break;
        default:
            plumber_print(pd, "pluck: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
