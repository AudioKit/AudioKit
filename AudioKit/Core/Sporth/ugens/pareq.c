#include "plumber.h"

int sporth_pareq(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT fc;
    SPFLOAT v;
    SPFLOAT q;
    SPFLOAT mode;
    sp_pareq *pareq;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "pareq: Creating\n");
#endif

            sp_pareq_create(&pareq);
            plumber_add_ugen(pd, SPORTH_PAREQ, pareq);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for pareq\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            mode = sporth_stack_pop_float(stack);
            q = sporth_stack_pop_float(stack);
            v = sporth_stack_pop_float(stack);
            fc = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "pareq: Initialising\n");
#endif

            mode = sporth_stack_pop_float(stack);
            q = sporth_stack_pop_float(stack);
            v = sporth_stack_pop_float(stack);
            fc = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            pareq = pd->last->ud;
            sp_pareq_init(pd->sp, pareq);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            mode = sporth_stack_pop_float(stack);
            q = sporth_stack_pop_float(stack);
            v = sporth_stack_pop_float(stack);
            fc = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            pareq = pd->last->ud;
            pareq->fc = fc;
            pareq->v = v;
            pareq->q = q;
            pareq->mode = mode;
            sp_pareq_compute(pd->sp, pareq, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            pareq = pd->last->ud;
            sp_pareq_destroy(&pareq);
            break;
        default:
            plumber_print(pd, "pareq: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
