#include <stdlib.h>
#include "plumber.h"

int sporth_conv(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT input;
    SPFLOAT out;
    
    char *ftname; 
    sp_ftbl *ft;
    SPFLOAT iPartLen;
    sp_conv *conv;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "conv: Creating\n");
#endif

            sp_conv_create(&conv);
            plumber_add_ugen(pd, SPORTH_CONV, conv);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for conv\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            iPartLen = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "conv: Initialising\n");
#endif

            ftname = sporth_stack_pop_string(stack);
            iPartLen = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            conv = pd->last->ud;
            
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            sp_conv_init(pd->sp, conv, ft, iPartLen);
            sporth_stack_push_float(stack, 0);

            break;
        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            conv = pd->last->ud;
            sp_conv_compute(pd->sp, conv, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            conv = pd->last->ud;
            sp_conv_destroy(&conv);
            break;
        default:
            plumber_print(pd, "conv: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
