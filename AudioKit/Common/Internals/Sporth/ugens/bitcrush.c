#include "plumber.h"

int sporth_bitcrush(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT bitdepth;
    SPFLOAT srate;
    sp_bitcrush *bitcrush;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "bitcrush: Creating\n");
#endif

            sp_bitcrush_create(&bitcrush);
            plumber_add_ugen(pd, SPORTH_BITCRUSH, bitcrush);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for bitcrush\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            srate = sporth_stack_pop_float(stack);
            bitdepth = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "bitcrush: Initialising\n");
#endif
            srate = sporth_stack_pop_float(stack);
            bitdepth = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            bitcrush = pd->last->ud;
            sp_bitcrush_init(pd->sp, bitcrush);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            srate = sporth_stack_pop_float(stack);
            bitdepth = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            bitcrush = pd->last->ud;
            bitcrush->bitdepth = bitdepth;
            bitcrush->srate = srate;
            sp_bitcrush_compute(pd->sp, bitcrush, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            bitcrush = pd->last->ud;
            sp_bitcrush_destroy(&bitcrush);
            break;
        default:
            fprintf(stderr, "bitcrush: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
