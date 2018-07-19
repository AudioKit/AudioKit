#include "plumber.h"

int sporth_atone(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT in;
    SPFLOAT out;
    SPFLOAT hp;
    sp_atone *atone;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "atone: Creating\n");
#endif

            sp_atone_create(&atone);
            plumber_add_ugen(pd, SPORTH_ATONE, atone);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for atone\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            hp = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "atone: Initialising\n");
#endif
            hp = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            atone = pd->last->ud;
            sp_atone_init(pd->sp, atone);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            hp = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            atone = pd->last->ud;
            atone->hp = hp;
            sp_atone_compute(pd->sp, atone, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            atone = pd->last->ud;
            sp_atone_destroy(&atone);
            break;
        default:
            plumber_print(pd, "atone: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
