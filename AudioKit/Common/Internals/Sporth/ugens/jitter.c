#include "plumber.h"

int sporth_jitter(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT amp;
    SPFLOAT cpsMin;
    SPFLOAT cpsMax;
    sp_jitter *jitter;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "jitter: Creating\n");
#endif

            sp_jitter_create(&jitter);
            plumber_add_ugen(pd, SPORTH_JITTER, jitter);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for jitter\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            cpsMax = sporth_stack_pop_float(stack);
            cpsMin = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "jitter: Initialising\n");
#endif
            cpsMax = sporth_stack_pop_float(stack);
            cpsMin = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            jitter = pd->last->ud;
            sp_jitter_init(pd->sp, jitter);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            cpsMax = sporth_stack_pop_float(stack);
            cpsMin = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            jitter = pd->last->ud;
            jitter->amp = amp;
            jitter->cpsMin = cpsMin;
            jitter->cpsMax = cpsMax;
            sp_jitter_compute(pd->sp, jitter, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            jitter = pd->last->ud;
            sp_jitter_destroy(&jitter);
            break;
        default:
            fprintf(stderr, "jitter: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
