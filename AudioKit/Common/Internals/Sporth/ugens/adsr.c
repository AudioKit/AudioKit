#include "plumber.h"

int sporth_adsr(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT gate;
    SPFLOAT out;
    SPFLOAT atk;
    SPFLOAT dec;
    SPFLOAT sus;
    SPFLOAT rel;
    sp_adsr *adsr;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "adsr: Creating\n");
#endif

            sp_adsr_create(&adsr);
            plumber_add_ugen(pd, SPORTH_ADSR, adsr);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for adsr\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            rel = sporth_stack_pop_float(stack);
            sus = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            gate = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "adsr: Initialising\n");
#endif

            rel = sporth_stack_pop_float(stack);
            sus = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            gate = sporth_stack_pop_float(stack);
            adsr = pd->last->ud;
            sp_adsr_init(pd->sp, adsr);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            rel = sporth_stack_pop_float(stack);
            sus = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            gate = sporth_stack_pop_float(stack);
            adsr = pd->last->ud;
            adsr->atk = atk;
            adsr->dec = dec;
            adsr->sus = sus;
            adsr->rel = rel;
            sp_adsr_compute(pd->sp, adsr, &gate, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            adsr = pd->last->ud;
            sp_adsr_destroy(&adsr);
            break;
        default:
            plumber_print(pd, "adsr: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
