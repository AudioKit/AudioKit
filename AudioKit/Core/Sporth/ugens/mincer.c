#include <stdlib.h>
#include "plumber.h"

int sporth_mincer(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out = 0;
    sp_ftbl * ft = NULL;
    const char *ftname = NULL;
    SPFLOAT time = 0;
    SPFLOAT amp = 0;
    SPFLOAT pitch = 0;
    SPFLOAT winsize = 0;
    sp_mincer *mincer = NULL;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "mincer: Creating\n");
#endif

            sp_mincer_create(&mincer);
            plumber_add_ugen(pd, SPORTH_MINCER, mincer);

            if(sporth_check_args(stack, "ffffs") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for mincer\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            ftname = sporth_stack_pop_string(stack);
            winsize = sporth_stack_pop_float(stack);
            pitch = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            time = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "mincer: Initialising\n");
#endif

            ftname = sporth_stack_pop_string(stack);
            winsize = sporth_stack_pop_float(stack);
            pitch = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            time = sporth_stack_pop_float(stack);
            mincer = pd->last->ud;

            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            sp_mincer_init(pd->sp, mincer, ft, winsize);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            winsize = sporth_stack_pop_float(stack);
            pitch = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            time = sporth_stack_pop_float(stack);
            mincer = pd->last->ud;
            mincer->time = time;
            mincer->amp = amp;
            mincer->pitch = pitch;
            sp_mincer_compute(pd->sp, mincer, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            mincer = pd->last->ud;
            sp_mincer_destroy(&mincer);
            break;
        default:
            plumber_print(pd, "mincer: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
