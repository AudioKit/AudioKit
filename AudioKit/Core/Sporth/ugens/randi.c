#include "plumber.h"

int sporth_randi(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT min;
    SPFLOAT max;
    SPFLOAT cps;
    sp_randi *randi;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "randi: Creating\n");
#endif

            sp_randi_create(&randi);
            plumber_add_ugen(pd, SPORTH_RANDI, randi);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for randi\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            cps = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "randi: Initialising\n");
#endif
            cps = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            randi = pd->last->ud;
            sp_randi_init(pd->sp, randi);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            cps = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            randi = pd->last->ud;
            randi->min = min;
            randi->max = max;
            randi->cps = cps;
            sp_randi_compute(pd->sp, randi, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            randi = pd->last->ud;
            sp_randi_destroy(&randi);
            break;
        default:
            plumber_print(pd, "randi: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
