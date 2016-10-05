#include "plumber.h"

int sporth_autowah(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT output;
    SPFLOAT level;
    SPFLOAT wah;
    SPFLOAT mix;
    sp_autowah *autowah;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "autowah: Creating\n");
#endif

            sp_autowah_create(&autowah);
            plumber_add_ugen(pd, SPORTH_AUTOWAH, autowah);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for autowah\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            mix = sporth_stack_pop_float(stack);
            wah = sporth_stack_pop_float(stack);
            level = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "autowah: Initialising\n");
#endif
            mix = sporth_stack_pop_float(stack);
            wah = sporth_stack_pop_float(stack);
            level = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            autowah = pd->last->ud;
            sp_autowah_init(pd->sp, autowah);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            mix = sporth_stack_pop_float(stack);
            wah = sporth_stack_pop_float(stack);
            level = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            autowah = pd->last->ud;
            *autowah->level = level;
            *autowah->wah = wah;
            *autowah->mix = mix;
            sp_autowah_compute(pd->sp, autowah, &input, &output);
            sporth_stack_push_float(stack, output);
            break;
        case PLUMBER_DESTROY:
            autowah = pd->last->ud;
            sp_autowah_destroy(&autowah);
            break;
        default:
            fprintf(stderr, "autowah: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
