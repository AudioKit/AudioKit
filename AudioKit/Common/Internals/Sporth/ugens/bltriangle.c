#include "plumber.h"

int sporth_bltriangle(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    SPFLOAT crest;
    sp_bltriangle *bltriangle;
    
    switch(pd->mode) {
        case PLUMBER_CREATE:
            
#ifdef DEBUG_MODE
            fprintf(stderr, "bltriangle: Creating\n");
#endif
            
            sp_bltriangle_create(&bltriangle);
            plumber_add_ugen(pd, SPORTH_TRIANGLE, bltriangle);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for bltriangle\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            
#ifdef DEBUG_MODE
            fprintf(stderr, "bltriangle: Initialising\n");
#endif
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            bltriangle = pd->last->ud;
            sp_bltriangle_init(pd->sp, bltriangle);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            bltriangle = pd->last->ud;
            *bltriangle->freq = freq;
            *bltriangle->amp = amp;
            *bltriangle->crest = crest;
            sp_bltriangle_compute(pd->sp, bltriangle, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            bltriangle = pd->last->ud;
            sp_bltriangle_destroy(&bltriangle);
            break;
        default:
            fprintf(stderr, "bltriangle: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
