#include "plumber.h"

int sporth_in(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT out;
    sp_in *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_in_create(&data);
            plumber_add_ugen(pd, SPORTH_IN, data);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;
            sp_in_init(pd->sp, data);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            data = pd->last->ud;
            sp_in_compute(pd->sp, data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_in_destroy(&data);
            break;
        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
