#include "plumber.h"

int sporth_delay1(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    sp_delay1 *delay1;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "delay1: Creating\n");
#endif

            sp_delay1_create(&delay1);
            plumber_add_ugen(pd, SPORTH_DELAY1, delay1);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "delay1: Initialising\n");
#endif

            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for delay1\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            input = sporth_stack_pop_float(stack);
            delay1 = pd->last->ud;
            sp_delay1_init(pd->sp, delay1);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for delay1\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            input = sporth_stack_pop_float(stack);
            delay1 = pd->last->ud;
            sp_delay1_compute(pd->sp, delay1, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            delay1 = pd->last->ud;
            sp_delay1_destroy(&delay1);
            break;
        default:
            fprintf(stderr, "delay1: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
