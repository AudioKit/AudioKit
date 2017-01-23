#include "plumber.h"

int sporth_switch(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT input_1;
    SPFLOAT input_2;
    SPFLOAT out;
    sp_switch *sw;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "switch: creating\n");
#endif

            sp_switch_create(&sw);
            plumber_add_ugen(pd, SPORTH_SWITCH, sw);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "switch: initialising\n");
#endif

            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for switch\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            trig = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            input_2 = sporth_stack_pop_float(stack);
            sw = pd->last->ud;
            sp_switch_init(pd->sp, sw);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            input_2 = sporth_stack_pop_float(stack);
            input_1 = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sw = pd->last->ud;
            sp_switch_compute(pd->sp, sw, &trig, &input_1, &input_2, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            sw = pd->last->ud;
            sp_switch_destroy(&sw);
            break;
        default:
            fprintf(stderr, "switch: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
