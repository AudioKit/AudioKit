#include <stdlib.h>
#include "plumber.h"

int sporth_tick(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out = 0;
    int tick = 0;
    plumbing *pipes;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tick: Creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_TICK, NULL);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tick: Initialising\n");
#endif
            pipes = plumber_get_pipes(pd);
            pipes->tick = 1;
            sporth_stack_push_float(stack, 1);
            break;
        case PLUMBER_COMPUTE:
            pipes = plumber_get_pipes(pd);
            tick = pipes->tick;
            if(tick == 1) {
                pipes->tick = 0;
                out = 1.0;
            } else {
                out = 0;
            } 
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd, "tick: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
