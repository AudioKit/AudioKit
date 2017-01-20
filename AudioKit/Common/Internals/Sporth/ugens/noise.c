#include "plumber.h"

int sporth_noise(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT amp;
    SPFLOAT out;
    sp_noise *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_noise_create(&data);
            plumber_add_ugen(pd, SPORTH_NOISE, data);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr, "Not enough arguments for noise\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;
            amp = sporth_stack_pop_float(stack);
            if(sp_noise_init(pd->sp, data) == SP_NOT_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            amp = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            data->amp = amp;
            sp_noise_compute(pd->sp, data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_noise_destroy(&data);
            break;
        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
