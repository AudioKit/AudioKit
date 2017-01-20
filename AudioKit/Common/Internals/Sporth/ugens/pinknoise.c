#include "plumber.h"

int sporth_pinknoise(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT amp;
    sp_pinknoise *pinknoise;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "pinknoise: Creating\n");
#endif

            sp_pinknoise_create(&pinknoise);
            plumber_add_ugen(pd, SPORTH_PINKNOISE, pinknoise);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for pinknoise\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "pinknoise: Initialising\n");
#endif

            amp = sporth_stack_pop_float(stack);
            pinknoise = pd->last->ud;
            sp_pinknoise_init(pd->sp, pinknoise);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            amp = sporth_stack_pop_float(stack);
            pinknoise = pd->last->ud;
            pinknoise->amp = amp;
            sp_pinknoise_compute(pd->sp, pinknoise, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            pinknoise = pd->last->ud;
            sp_pinknoise_destroy(&pinknoise);
            break;
        default:
            fprintf(stderr, "pinknoise: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
