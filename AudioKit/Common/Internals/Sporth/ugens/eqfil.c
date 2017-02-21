#include "plumber.h"

int sporth_eqfil(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT freq;
    SPFLOAT bw;
    SPFLOAT gain;
    sp_eqfil *eqfil;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "eqfil: Creating\n");
#endif

            sp_eqfil_create(&eqfil);
            plumber_add_ugen(pd, SPORTH_EQFIL, eqfil);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for eqfil\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "eqfil: Initialising\n");
#endif

            gain = sporth_stack_pop_float(stack);
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            eqfil = pd->last->ud;
            sp_eqfil_init(pd->sp, eqfil);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            gain = sporth_stack_pop_float(stack);
            bw = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            eqfil = pd->last->ud;
            eqfil->freq = freq;
            eqfil->bw = bw;
            eqfil->gain = gain;
            sp_eqfil_compute(pd->sp, eqfil, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            eqfil = pd->last->ud;
            sp_eqfil_destroy(&eqfil);
            break;
        default:
            plumber_print(pd, "eqfil: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
