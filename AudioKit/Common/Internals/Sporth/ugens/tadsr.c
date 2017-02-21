#include "plumber.h"

int sporth_tadsr(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT atk;
    SPFLOAT dec;
    SPFLOAT sus;
    SPFLOAT rel;
    sp_tadsr *tadsr;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tadsr: Creating\n");
#endif

            sp_tadsr_create(&tadsr);
            plumber_add_ugen(pd, SPORTH_TADSR, tadsr);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for tadsr\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            rel = sporth_stack_pop_float(stack);
            sus = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tadsr: Initialising\n");
#endif

            rel = sporth_stack_pop_float(stack);
            sus = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tadsr = pd->last->ud;
            sp_tadsr_init(pd->sp, tadsr);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            rel = sporth_stack_pop_float(stack);
            sus = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tadsr = pd->last->ud;
            tadsr->atk = atk;
            tadsr->dec = dec;
            tadsr->sus = sus;
            tadsr->rel = rel;
            sp_tadsr_compute(pd->sp, tadsr, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tadsr = pd->last->ud;
            sp_tadsr_destroy(&tadsr);
            break;
        default:
            plumber_print(pd, "tadsr: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
