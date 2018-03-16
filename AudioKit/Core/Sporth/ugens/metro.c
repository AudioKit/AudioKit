#include "plumber.h"

int sporth_metro(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT freq;
    SPFLOAT out;
    sp_metro *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_metro_create(&data);
            plumber_add_ugen(pd, SPORTH_METRO, data);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for metro\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;
            sp_metro_init(pd->sp, data);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            freq = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            data->freq = freq;
            sp_metro_compute(pd->sp, data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_metro_destroy(&data);
            break;
        default:
          plumber_print(pd,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
