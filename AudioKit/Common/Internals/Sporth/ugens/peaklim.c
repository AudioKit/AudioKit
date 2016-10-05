#include "plumber.h"

int sporth_peaklim(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT atk;
    SPFLOAT rel;
    SPFLOAT thresh;
    sp_peaklim *peaklim;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "peaklim: Creating\n");
#endif

            sp_peaklim_create(&peaklim);
            plumber_add_ugen(pd, SPORTH_PEAKLIM, peaklim);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for peaklim\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            thresh = sporth_stack_pop_float(stack);
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "peaklim: Initialising\n");
#endif

            thresh = sporth_stack_pop_float(stack);
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            peaklim = pd->last->ud;
            sp_peaklim_init(pd->sp, peaklim);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            thresh = sporth_stack_pop_float(stack);
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            peaklim = pd->last->ud;
            peaklim->atk = atk;
            peaklim->rel = rel;
            peaklim->thresh = thresh;
            sp_peaklim_compute(pd->sp, peaklim, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            peaklim = pd->last->ud;
            sp_peaklim_destroy(&peaklim);
            break;
        default:
            fprintf(stderr, "peaklim: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
