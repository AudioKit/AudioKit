#include "plumber.h"

int sporth_lpf18(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT cutoff;
    SPFLOAT res;
    SPFLOAT dist;
    sp_lpf18 *lpf18;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "lpf18: Creating\n");
#endif

            sp_lpf18_create(&lpf18);
            plumber_add_ugen(pd, SPORTH_LPF18, lpf18);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for lpf18\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "lpf18: Initialising\n");
#endif

            dist = sporth_stack_pop_float(stack);
            res = sporth_stack_pop_float(stack);
            cutoff = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            lpf18 = pd->last->ud;
            sp_lpf18_init(pd->sp, lpf18);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            dist = sporth_stack_pop_float(stack);
            res = sporth_stack_pop_float(stack);
            cutoff = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            lpf18 = pd->last->ud;
            lpf18->cutoff = cutoff;
            lpf18->res = res;
            lpf18->dist = dist;
            sp_lpf18_compute(pd->sp, lpf18, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            lpf18 = pd->last->ud;
            sp_lpf18_destroy(&lpf18);
            break;
        default:
            plumber_print(pd, "lpf18: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
