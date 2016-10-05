#include <stdlib.h>
#include "plumber.h"

int sporth_paulstretch(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    char *ftname;
    sp_ftbl * ft;
    SPFLOAT windowsize;
    SPFLOAT stretch;
    sp_paulstretch *paulstretch;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "paulstretch: Creating\n");
#endif

            sp_paulstretch_create(&paulstretch);
            plumber_add_ugen(pd, SPORTH_PAULSTRETCH, paulstretch);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for paulstretch\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            windowsize = sporth_stack_pop_float(stack);
            stretch = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sp_paulstretch_init(pd->sp, paulstretch, ft, windowsize, stretch);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "paulstretch: Initialising\n");
#endif

            ftname = sporth_stack_pop_string(stack);
            windowsize = sporth_stack_pop_float(stack);
            stretch = sporth_stack_pop_float(stack);
            paulstretch = pd->last->ud;
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            windowsize = sporth_stack_pop_float(stack);
            stretch = sporth_stack_pop_float(stack);
            paulstretch = pd->last->ud;
            paulstretch->stretch = stretch;
            sp_paulstretch_compute(pd->sp, paulstretch, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            paulstretch = pd->last->ud;
            sp_paulstretch_destroy(&paulstretch);
            break;
        default:
            fprintf(stderr, "paulstretch: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
