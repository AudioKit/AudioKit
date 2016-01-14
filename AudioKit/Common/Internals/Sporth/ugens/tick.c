#include <stdlib.h>
#include "plumber.h"

int sporth_tick(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out = 0;
    int *tick;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "tick: Creating\n");
#endif
            tick = malloc(sizeof(int));    
            plumber_add_ugen(pd, SPORTH_TICK, tick);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "tick: Initialising\n");
#endif
            tick = pd->last->ud;
            *tick = 1;
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            tick = pd->last->ud;
            if(*tick == 1) {
                *tick = 0;
                out = 1.0;
            } else {
                out = 0;
            } 
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tick = pd->last->ud;
            free(tick);
            break;
        default:
            fprintf(stderr, "tick: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
