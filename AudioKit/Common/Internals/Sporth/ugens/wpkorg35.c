#include "plumber.h"

int sporth_wpkorg35(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT cutoff;
    SPFLOAT res;
    SPFLOAT saturation;
    sp_wpkorg35 *wpkorg35;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "wpkorg35: Creating\n");
#endif

            sp_wpkorg35_create(&wpkorg35);
            plumber_add_ugen(pd, SPORTH_WPKORG35, wpkorg35);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for wpkorg35\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            saturation = sporth_stack_pop_float(stack);
            res = sporth_stack_pop_float(stack);
            cutoff = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "wpkorg35: Initialising\n");
#endif

            saturation = sporth_stack_pop_float(stack);
            res = sporth_stack_pop_float(stack);
            cutoff = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            wpkorg35 = pd->last->ud;
            sp_wpkorg35_init(pd->sp, wpkorg35);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            saturation = sporth_stack_pop_float(stack);
            res = sporth_stack_pop_float(stack);
            cutoff = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            wpkorg35 = pd->last->ud;
            wpkorg35->cutoff = cutoff;
            wpkorg35->res = res;
            wpkorg35->saturation = saturation;
            sp_wpkorg35_compute(pd->sp, wpkorg35, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            wpkorg35 = pd->last->ud;
            sp_wpkorg35_destroy(&wpkorg35);
            break;
        default:
            fprintf(stderr, "wpkorg35: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
