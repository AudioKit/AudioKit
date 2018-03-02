#include "plumber.h"

int sporth_tseg(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT ibeg;
    SPFLOAT end;
    SPFLOAT dur;
    SPFLOAT type;
    sp_tseg *tseg;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tseg: Creating\n");
#endif

            sp_tseg_create(&tseg);
            plumber_add_ugen(pd, SPORTH_TSEG, tseg);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for tseg\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ibeg = sporth_stack_pop_float(stack);
            type = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            end = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tseg: Initialising\n");
#endif

            ibeg = sporth_stack_pop_float(stack);
            type = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            end = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tseg = pd->last->ud;
            sp_tseg_init(pd->sp, tseg, ibeg);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            ibeg = sporth_stack_pop_float(stack);
            type = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            end = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tseg = pd->last->ud;
            tseg->end = end;
            tseg->dur = dur;
            tseg->type = type;
            sp_tseg_compute(pd->sp, tseg, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tseg = pd->last->ud;
            sp_tseg_destroy(&tseg);
            break;
        default:
            plumber_print(pd, "tseg: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
