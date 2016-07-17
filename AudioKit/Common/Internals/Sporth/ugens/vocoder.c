#include "plumber.h"

int sporth_vocoder(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT source;
    SPFLOAT excite;
    SPFLOAT out;
    SPFLOAT atk;
    SPFLOAT rel;
    SPFLOAT bwratio;
    sp_vocoder *vocoder;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "vocoder: Creating\n");
#endif

            sp_vocoder_create(&vocoder);
            plumber_add_ugen(pd, SPORTH_VOCODER, vocoder);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for vocoder\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            bwratio = sporth_stack_pop_float(stack);
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            source = sporth_stack_pop_float(stack);
            excite = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "vocoder: Initialising\n");
#endif

            bwratio = sporth_stack_pop_float(stack);
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            source = sporth_stack_pop_float(stack);
            excite = sporth_stack_pop_float(stack);
            vocoder = pd->last->ud;
            sp_vocoder_init(pd->sp, vocoder);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            bwratio = sporth_stack_pop_float(stack);
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            source = sporth_stack_pop_float(stack);
            excite = sporth_stack_pop_float(stack);
            vocoder = pd->last->ud;
            *vocoder->atk = atk;
            *vocoder->rel = rel;
            *vocoder->bwratio = bwratio;
            sp_vocoder_compute(pd->sp, vocoder, &source, &excite, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            vocoder = pd->last->ud;
            sp_vocoder_destroy(&vocoder);
            break;
        default:
            fprintf(stderr, "vocoder: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
