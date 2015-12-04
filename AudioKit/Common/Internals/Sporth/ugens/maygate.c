#include "plumber.h"

int sporth_maygate(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT prob;
    int mode;
    sp_maygate *maygate;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "maygate: Creating\n");
#endif

            sp_maygate_create(&maygate);
            plumber_add_module(pd, SPORTH_MAYGATE, maygate);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "maygate: Initialising\n");
#endif

            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for maygate\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            mode = sporth_stack_pop_float(stack);
            prob = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            maygate = pd->last->ud;
            sp_maygate_init(pd->sp, maygate);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for maygate\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            mode = sporth_stack_pop_float(stack);
            prob = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            maygate = pd->last->ud;
            maygate->prob = prob;
            maygate->mode = mode;
            sp_maygate_compute(pd->sp, maygate, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            maygate = pd->last->ud;
            sp_maygate_destroy(&maygate);
            break;
        default:
            fprintf(stderr, "maygate: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
