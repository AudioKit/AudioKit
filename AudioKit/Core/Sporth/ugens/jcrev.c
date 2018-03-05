#include "plumber.h"

int sporth_jcrev(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    sp_jcrev *jcrev;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "jcrev: Creating\n");
#endif

            sp_jcrev_create(&jcrev);
            plumber_add_ugen(pd, SPORTH_JCREV, jcrev);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for jcrev\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "jcrev: Initialising\n");
#endif
            input = sporth_stack_pop_float(stack);
            jcrev = pd->last->ud;
            sp_jcrev_init(pd->sp, jcrev);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            input = sporth_stack_pop_float(stack);
            jcrev = pd->last->ud;
            sp_jcrev_compute(pd->sp, jcrev, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            jcrev = pd->last->ud;
            sp_jcrev_destroy(&jcrev);
            break;
        default:
            plumber_print(pd, "jcrev: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
