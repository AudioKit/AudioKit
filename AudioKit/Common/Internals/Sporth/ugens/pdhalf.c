#include "plumber.h"

int sporth_pdhalf(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT sig;
    SPFLOAT out;
    SPFLOAT amount;
    sp_pdhalf *pdhalf;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "pdhalf: Creating\n");
#endif

            sp_pdhalf_create(&pdhalf);
            plumber_add_ugen(pd, SPORTH_PDHALF, pdhalf);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for pdhalf\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amount = sporth_stack_pop_float(stack);
            sig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "pdhalf: Initialising\n");
#endif

            amount = sporth_stack_pop_float(stack);
            sig = sporth_stack_pop_float(stack);
            pdhalf = pd->last->ud;
            sp_pdhalf_init(pd->sp, pdhalf);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            amount = sporth_stack_pop_float(stack);
            sig = sporth_stack_pop_float(stack);
            pdhalf = pd->last->ud;
            pdhalf->amount = amount;
            sp_pdhalf_compute(pd->sp, pdhalf, &sig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            pdhalf = pd->last->ud;
            sp_pdhalf_destroy(&pdhalf);
            break;
        default:
            fprintf(stderr, "pdhalf: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
