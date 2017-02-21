#include "plumber.h"

int sporth_fosc(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    sp_ftbl *tbl;
    char *str;
    SPFLOAT freq;
    SPFLOAT amp;
    SPFLOAT car;
    SPFLOAT mod;
    SPFLOAT indx;
    sp_fosc *fosc;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "fosc: Creating\n");
#endif

            sp_fosc_create(&fosc);
            plumber_add_ugen(pd, SPORTH_FOSC, fosc);
            if(sporth_check_args(stack, "fffffs") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fosc\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            indx = sporth_stack_pop_float(stack);
            mod = sporth_stack_pop_float(stack);
            car = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            if(plumber_ftmap_search(pd, str, &tbl) != PLUMBER_OK) {
                plumber_print(pd, "fosc: could not find ftable %s\n", str);
                return PLUMBER_NOTOK;
            }
            sp_fosc_init(pd->sp, fosc, tbl);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "fosc: Initialising\n");
#endif

            str = sporth_stack_pop_string(stack);
            indx = sporth_stack_pop_float(stack);
            mod = sporth_stack_pop_float(stack);
            car = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            fosc = pd->last->ud;
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            indx = sporth_stack_pop_float(stack);
            mod = sporth_stack_pop_float(stack);
            car = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);
            fosc = pd->last->ud;
            fosc->freq = freq;
            fosc->amp = amp;
            fosc->car = car;
            fosc->mod = mod;
            fosc->indx = indx;
            sp_fosc_compute(pd->sp, fosc, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            fosc = pd->last->ud;
            sp_fosc_destroy(&fosc);
            break;
        default:
            plumber_print(pd, "fosc: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
