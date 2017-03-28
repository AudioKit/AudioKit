#include "plumber.h"

int sporth_ptrack(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT freq;
    SPFLOAT amp;
    int ihopsize;
    int ipeaks;
    sp_ptrack *ptrack;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "ptrack: Creating\n");
#endif

            sp_ptrack_create(&ptrack);
            plumber_add_ugen(pd, SPORTH_PTRACK, ptrack);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for ptrack\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ihopsize = sporth_stack_pop_float(stack);
            ipeaks = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "ptrack: Initialising\n");
#endif

            ihopsize = sporth_stack_pop_float(stack);
            ipeaks = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            ptrack = pd->last->ud;
            sp_ptrack_init(pd->sp, ptrack, ihopsize, ipeaks);
            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            ihopsize = sporth_stack_pop_float(stack);
            ipeaks = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            ptrack = pd->last->ud;
            sp_ptrack_compute(pd->sp, ptrack, &in, &freq, &amp);
            sporth_stack_push_float(stack, freq);
            sporth_stack_push_float(stack, amp);
            break;
        case PLUMBER_DESTROY:
            ptrack = pd->last->ud;
            sp_ptrack_destroy(&ptrack);
            break;
        default:
            plumber_print(pd, "ptrack: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
