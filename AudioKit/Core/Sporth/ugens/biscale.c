#include "plumber.h"

int sporth_biscale(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT min;
    SPFLOAT max;
    sp_biscale *biscale;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "biscale: Creating\n");
#endif

            sp_biscale_create(&biscale);
            plumber_add_ugen(pd, SPORTH_BISCALE, biscale);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for biscale\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "biscale: Initialising\n");
#endif
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            biscale = pd->last->ud;
            sp_biscale_init(pd->sp, biscale);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            biscale = pd->last->ud;
            biscale->min = min;
            biscale->max = max;
            sp_biscale_compute(pd->sp, biscale, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            biscale = pd->last->ud;
            sp_biscale_destroy(&biscale);
            break;
        default:
            plumber_print(pd, "biscale: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
