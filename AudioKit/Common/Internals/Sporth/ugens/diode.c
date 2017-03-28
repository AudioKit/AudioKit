#include "plumber.h"

int sporth_diode(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out_left;
    SPFLOAT freq;
    SPFLOAT res;
    sp_diode *diode;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "diode: Creating\n");
#endif

            sp_diode_create(&diode);
            plumber_add_ugen(pd, SPORTH_DIODE, diode);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for diode\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            res = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "diode: Initialising\n");
#endif

            res = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            diode = pd->last->ud;
            sp_diode_init(pd->sp, diode);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            res = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            diode = pd->last->ud;
            diode->freq = freq;
            diode->res = res;
            sp_diode_compute(pd->sp, diode, &input, &out_left);
            sporth_stack_push_float(stack, out_left);
            break;
        case PLUMBER_DESTROY:
            diode = pd->last->ud;
            sp_diode_destroy(&diode);
            break;
        default:
            plumber_print(pd, "diode: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
