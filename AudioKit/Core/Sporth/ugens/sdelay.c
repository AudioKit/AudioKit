#include "plumber.h"

int sporth_sdelay(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT size;
    sp_sdelay *sdelay;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "sdelay: Creating\n");
#endif

            sp_sdelay_create(&sdelay);
            plumber_add_ugen(pd, SPORTH_SDELAY, sdelay);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for sdelay\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            size = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "sdelay: Initialising\n");
#endif

            size = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sdelay = pd->last->ud;
            sp_sdelay_init(pd->sp, sdelay, size);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            size = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sdelay = pd->last->ud;
            sp_sdelay_compute(pd->sp, sdelay, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            sdelay = pd->last->ud;
            sp_sdelay_destroy(&sdelay);
            break;
        default:
            plumber_print(pd, "sdelay: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
