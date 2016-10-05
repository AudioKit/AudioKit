#include "plumber.h"

int sporth_tin(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    sp_tin *tin;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "tin: Creating\n");
#endif

            sp_tin_create(&tin);
            plumber_add_ugen(pd, SPORTH_TIN, tin);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for tin\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "tin: Initialising\n");
#endif
            trig = sporth_stack_pop_float(stack);
            tin = pd->last->ud;
            sp_tin_init(pd->sp, tin);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            trig = sporth_stack_pop_float(stack);
            tin = pd->last->ud;
            sp_tin_compute(pd->sp, tin, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tin = pd->last->ud;
            sp_tin_destroy(&tin);
            break;
        default:
            fprintf(stderr, "tin: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
