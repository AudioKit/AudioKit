#include <stdlib.h>
#include "plumber.h"

int sporth_dtrig(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    sp_ftbl * ft;
    const char *ftname;
    int loop;
    SPFLOAT delay, scale;
    sp_dtrig *dtrig;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "dtrig: Creating\n");
#endif

            sp_dtrig_create(&dtrig);
            plumber_add_ugen(pd, SPORTH_DTRIG, dtrig);
            if(sporth_check_args(stack, "ffffs") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for dtrig\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            scale = sporth_stack_pop_float(stack);
            delay = sporth_stack_pop_float(stack);
            loop = (int)sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);

            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "dtrig: Initialising\n");
#endif

            ftname = sporth_stack_pop_string(stack);
            scale = sporth_stack_pop_float(stack);
            delay = sporth_stack_pop_float(stack);
            loop = (int)sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            dtrig = pd->last->ud;

            plumber_ftmap_search(pd, ftname, &ft);

            sp_dtrig_init(pd->sp, dtrig, ft);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            scale = sporth_stack_pop_float(stack);
            delay = sporth_stack_pop_float(stack);
            loop = (int)sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            dtrig = pd->last->ud;
            dtrig->loop = loop;
            dtrig->delay = delay;
            dtrig->scale = scale;
            sp_dtrig_compute(pd->sp, dtrig, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            dtrig = pd->last->ud;
            sp_dtrig_destroy(&dtrig);
            break;
        default:
            plumber_print(pd, "dtrig: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
