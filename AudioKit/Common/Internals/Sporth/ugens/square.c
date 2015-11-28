#include "plumber.h"

int sporth_square(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT amp;
    SPFLOAT width;
    sp_square *square;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "square: Creating\n");
#endif

            sp_square_create(&square);
            plumber_add_module(pd, SPORTH_SQUARE, sizeof(sp_square), square);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "square: Initialising\n");
#endif

            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for square\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            width = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            square = pd->last->ud;
            sp_square_init(pd->sp, square);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for square\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            width = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            square = pd->last->ud;
            *square->freq = freq;
            *square->amp = amp;
            *square->width = width;
            sp_square_compute(pd->sp, square, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            square = pd->last->ud;
            sp_square_destroy(&square);
            break;
        default:
            fprintf(stderr, "square: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
