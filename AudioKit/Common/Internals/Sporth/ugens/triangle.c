#include "plumber.h"

int sporth_triangle(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    sp_triangle *triangle;
    
    switch(pd->mode) {
        case PLUMBER_CREATE:
            
#ifdef DEBUG_MODE
            fprintf(stderr, "triangle: Creating\n");
#endif
            
            sp_triangle_create(&triangle);
            plumber_add_ugen(pd, SPORTH_TRIANGlE, triangle);
            break;
        case PLUMBER_INIT:
            
#ifdef DEBUG_MODE
            fprintf(stderr, "triangle: Initialising\n");
#endif
            
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for triangle\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            triangle = pd->last->ud;
            sp_triangle_init(pd->sp, triangle);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for triangle\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            triangle = pd->last->ud;
            *triangle->freq = freq;
            *triangle->amp = amp;
            sp_triangle_compute(pd->sp, triangle, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            triangle = pd->last->ud;
            sp_triangle_destroy(&triangle);
            break;
        default:
            fprintf(stderr, "triangle: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
