#include <stdlib.h>
#include "plumber.h"

int sporth_mincer(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out = 0;
    sp_ftbl * ft = NULL;
    char *ftname = NULL;
    SPFLOAT time = 0;
    SPFLOAT amp = 0;
    SPFLOAT pitch = 0;
    sp_mincer *mincer = NULL;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "mincer: Creating\n");
#endif

            sp_mincer_create(&mincer);
            plumber_add_ugen(pd, SPORTH_MINCER, mincer);

            if(sporth_check_args(stack, "fffs") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for mincer\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            ftname = sporth_stack_pop_string(stack);
            pitch = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            time = sporth_stack_pop_float(stack);
            free(ftname);

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "mincer: Initialising\n");
#endif

            ftname = sporth_stack_pop_string(stack);
            pitch = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            time = sporth_stack_pop_float(stack);
            mincer = pd->last->ud;

            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            free(ftname);
            sp_mincer_init(pd->sp, mincer, ft);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            pitch = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            time = sporth_stack_pop_float(stack);
            mincer = pd->last->ud;
            mincer->time = time;
            mincer->amp = amp;
            mincer->pitch = pitch;
            sp_mincer_compute(pd->sp, mincer, NULL, &out);
            sporth_stack_push_float(stack, out);
            free(ftname);
            break;
        case PLUMBER_DESTROY:
            mincer = pd->last->ud;
            sp_mincer_destroy(&mincer);
            break;
        default:
            fprintf(stderr, "mincer: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
