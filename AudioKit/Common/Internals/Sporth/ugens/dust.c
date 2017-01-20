#include "plumber.h"

int sporth_dust(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT amp;
    SPFLOAT density;
    int bipolar;
    sp_dust *dust;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "dust: Creating\n");
#endif

            sp_dust_create(&dust);
            plumber_add_ugen(pd, SPORTH_DUST, dust);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for dust\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "dust: Initialising\n");
#endif

            bipolar = (int)sporth_stack_pop_float(stack);
            density = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            dust = pd->last->ud;
            sp_dust_init(pd->sp, dust);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            bipolar = (int)sporth_stack_pop_float(stack);
            density = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            dust = pd->last->ud;
            dust->amp = amp;
            dust->density = density;
            dust->bipolar = bipolar;
            sp_dust_compute(pd->sp, dust, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            dust = pd->last->ud;
            sp_dust_destroy(&dust);
            break;
        default:
            fprintf(stderr, "dust: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
