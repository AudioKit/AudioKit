#include "plumber.h"

int sporth_tenvx(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT atk;
    SPFLOAT hold;
    SPFLOAT rel;
    sp_tenvx *tenvx;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "tenvx: Creating\n");
#endif

            sp_tenvx_create(&tenvx);
            plumber_add_ugen(pd, SPORTH_TENVX, tenvx);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for tenvx\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            rel = sporth_stack_pop_float(stack);
            hold = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "tenvx: Initialising\n");
#endif

            rel = sporth_stack_pop_float(stack);
            hold = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tenvx = pd->last->ud;
            sp_tenvx_init(pd->sp, tenvx);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            rel = sporth_stack_pop_float(stack);
            hold = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tenvx = pd->last->ud;
            tenvx->atk = atk;
            tenvx->hold = hold;
            tenvx->rel = rel;
            sp_tenvx_compute(pd->sp, tenvx, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tenvx = pd->last->ud;
            sp_tenvx_destroy(&tenvx);
            break;
        default:
            plumber_print(pd, "tenvx: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
