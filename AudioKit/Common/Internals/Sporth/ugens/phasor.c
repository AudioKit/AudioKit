#include "plumber.h"

int sporth_phasor(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT iphs;
    SPFLOAT freq;
    sp_phasor *phasor;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "phasor: Creating\n");
#endif

            sp_phasor_create(&phasor);
            plumber_add_ugen(pd, SPORTH_PHASOR, phasor);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for phasor\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            iphs = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "phasor: Initialising\n");
#endif
            iphs = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            phasor = pd->last->ud;
            sp_phasor_init(pd->sp, phasor, iphs);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            iphs = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            phasor = pd->last->ud;
            phasor->freq = freq;
            sp_phasor_compute(pd->sp, phasor, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            phasor = pd->last->ud;
            sp_phasor_destroy(&phasor);
            break;
        default:
            fprintf(stderr, "phasor: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
