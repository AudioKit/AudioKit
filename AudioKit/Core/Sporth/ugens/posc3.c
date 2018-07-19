#include <stdlib.h>
#include "plumber.h"

int sporth_posc3(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    sp_ftbl *tbl;
    const char *str;
    SPFLOAT freq;
    SPFLOAT amp;
    sp_posc3 *posc3;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "posc3: Creating\n");
#endif

            sp_posc3_create(&posc3);
            plumber_add_ugen(pd, SPORTH_POSC3, posc3);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for posc3\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search(pd, str, &tbl) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sp_posc3_init(pd->sp, posc3, tbl);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "posc3: Initialising\n");
#endif

            str = sporth_stack_pop_string(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            posc3 = pd->last->ud;

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            posc3 = pd->last->ud;
            posc3->freq = freq;
            posc3->amp = amp;
            sp_posc3_compute(pd->sp, posc3, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            posc3 = pd->last->ud;
            sp_posc3_destroy(&posc3);
            break;
        default:
            plumber_print(pd, "posc3: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
