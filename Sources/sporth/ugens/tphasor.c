#include "plumber.h"

int sporth_tphasor(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT iphs;
    SPFLOAT freq;
    SPFLOAT trig;
    sp_phasor *tphasor;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tphasor: Creating\n");
#endif

            sp_phasor_create(&tphasor);
            plumber_add_ugen(pd, SPORTH_TPHASOR, tphasor);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for tphasor\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            iphs = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tphasor: Initialising\n");
#endif
            iphs = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tphasor = pd->last->ud;
            sp_phasor_init(pd->sp, tphasor, iphs);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            iphs = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tphasor = pd->last->ud;
            tphasor->freq = freq;

            if(trig != 0) {
                tphasor->curphs = iphs;
            }

            sp_phasor_compute(pd->sp, tphasor, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tphasor = pd->last->ud;
            sp_phasor_destroy(&tphasor);
            break;
        default:
            plumber_print(pd, "tphasor: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
