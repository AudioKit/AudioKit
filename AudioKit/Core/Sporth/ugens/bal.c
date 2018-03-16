#include "plumber.h"

int sporth_bal(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT sig;
    SPFLOAT comp;
    SPFLOAT out;
    sp_bal *bal;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "bal: Creating\n");
#endif

            sp_bal_create(&bal);
            plumber_add_ugen(pd, SPORTH_BAL, bal);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for bal\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sig = sporth_stack_pop_float(stack);
            comp = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "bal: Initialising\n");
#endif

            sig = sporth_stack_pop_float(stack);
            comp = sporth_stack_pop_float(stack);
            bal = pd->last->ud;
            sp_bal_init(pd->sp, bal);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            sig = sporth_stack_pop_float(stack);
            comp = sporth_stack_pop_float(stack);
            bal = pd->last->ud;
            sp_bal_compute(pd->sp, bal, &sig, &comp, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            bal = pd->last->ud;
            sp_bal_destroy(&bal);
            break;
        default:
            plumber_print(pd, "bal: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
