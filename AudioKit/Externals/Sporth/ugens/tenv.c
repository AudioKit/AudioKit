#include "plumber.h"

int sporth_tenv(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT trig, attack, hold, release;

    SPFLOAT out = 0;
    sp_tenv *data;

    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_tenv_create(&data);
            plumber_add_ugen(pd, SPORTH_TENV, data);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd, "Init: not enough arguments for tenv\n");
                return PLUMBER_NOTOK;
            }
            release = sporth_stack_pop_float(stack);
            hold = sporth_stack_pop_float(stack);
            attack = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            break;

        case PLUMBER_INIT:
            release = sporth_stack_pop_float(stack);
            hold = sporth_stack_pop_float(stack);
            attack = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            sp_tenv_init(pd->sp, data);
            sporth_stack_push_float(stack, 0);
            break;

        case PLUMBER_COMPUTE:
            release = sporth_stack_pop_float(stack);
            hold = sporth_stack_pop_float(stack);
            attack = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            data = pd->last->ud;
            data->atk = attack;
            data->rel = release;
            data->hold = hold;
            sp_tenv_compute(pd->sp, data, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;

        case PLUMBER_DESTROY:
#ifdef DEBUG_MODE
            plumber_print(pd, "Destroying tenv\n");
#endif
            data = pd->last->ud;
            sp_tenv_destroy(&data);
            break;

        default:
           plumber_print(pd, "Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
