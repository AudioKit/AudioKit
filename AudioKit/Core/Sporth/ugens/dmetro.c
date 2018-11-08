#include "plumber.h"

int sporth_dmetro(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT time;
    sp_dmetro *dmetro;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "dmetro: Creating\n");
#endif

            sp_dmetro_create(&dmetro);
            plumber_add_ugen(pd, SPORTH_DMETRO, dmetro);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for dmetro\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            time = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "dmetro: Initialising\n");
#endif

            time = sporth_stack_pop_float(stack);
            dmetro = pd->last->ud;
            sp_dmetro_init(pd->sp, dmetro);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            time = sporth_stack_pop_float(stack);
            dmetro = pd->last->ud;
            dmetro->time = time;
            sp_dmetro_compute(pd->sp, dmetro, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            dmetro = pd->last->ud;
            sp_dmetro_destroy(&dmetro);
            break;
        default:
            plumber_print(pd, "dmetro: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
