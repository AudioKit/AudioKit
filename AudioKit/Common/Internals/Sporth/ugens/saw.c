#include "plumber.h"

int sporth_saw(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    sp_saw *saw;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "saw: Creating\n");
#endif

            sp_saw_create(&saw);
            plumber_add_module(pd, SPORTH_SAW, sizeof(sp_saw), saw);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "saw: Initialising\n");
#endif

            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for saw\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            saw = pd->last->ud;
            sp_saw_init(pd->sp, saw);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for saw\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            saw = pd->last->ud;
            *saw->freq = freq;
            *saw->amp = amp;
            sp_saw_compute(pd->sp, saw, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            saw = pd->last->ud;
            sp_saw_destroy(&saw);
            break;
        default:
            fprintf(stderr, "saw: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
