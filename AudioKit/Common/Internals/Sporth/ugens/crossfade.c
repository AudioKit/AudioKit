#include "plumber.h"

int sporth_crossfade(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in1;
    SPFLOAT in2;
    SPFLOAT out;
    SPFLOAT pos;
    sp_crossfade *crossfade;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "crossfade: Creating\n");
#endif

            sp_crossfade_create(&crossfade);
            plumber_add_ugen(pd, SPORTH_CROSSFADE, crossfade);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for crossfade\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            pos = sporth_stack_pop_float(stack);
            in1 = sporth_stack_pop_float(stack);
            in2 = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "crossfade: Initialising\n");
#endif

            pos = sporth_stack_pop_float(stack);
            in1 = sporth_stack_pop_float(stack);
            in2 = sporth_stack_pop_float(stack);
            crossfade = pd->last->ud;
            sp_crossfade_init(pd->sp, crossfade);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            pos = sporth_stack_pop_float(stack);
            in1 = sporth_stack_pop_float(stack);
            in2 = sporth_stack_pop_float(stack);
            crossfade = pd->last->ud;
            crossfade->pos = pos;
            sp_crossfade_compute(pd->sp, crossfade, &in1, &in2, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            crossfade = pd->last->ud;
            sp_crossfade_destroy(&crossfade);
            break;
        default:
            fprintf(stderr, "crossfade: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
