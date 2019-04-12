#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

typedef struct {
    sp_fosc *osc;
    sp_ftbl *ft;
} sporth_fm_d;

int sporth_fm(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT out = 0, amp, freq, car, mod, index;
    sporth_fm_d *fm;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
           plumber_print(pd,"creating FM function... \n");
#endif
            fm = malloc(sizeof(sporth_fm_d));
            sp_ftbl_create(pd->sp, &fm->ft, 8192);
            sp_fosc_create(&fm->osc);
            plumber_add_ugen(pd, SPORTH_FM, fm);
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            index = sporth_stack_pop_float(stack);
            mod = sporth_stack_pop_float(stack);
            car = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
            fm = pd->last->ud;

            index = sporth_stack_pop_float(stack);
            mod = sporth_stack_pop_float(stack);
            car = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            sp_gen_sine(pd->sp, fm->ft);
            sp_fosc_init(pd->sp, fm->osc, fm->ft);
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_COMPUTE:
            fm = pd->last->ud;
            if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            index = sporth_stack_pop_float(stack);
            mod = sporth_stack_pop_float(stack);
            car = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            freq = sporth_stack_pop_float(stack);

            fm->osc->freq = freq;
            fm->osc->amp = amp;
            fm->osc->car = car;
            fm->osc->mod = mod;
            fm->osc->indx = index;

            sp_fosc_compute(pd->sp, fm->osc, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            fm = pd->last->ud;
            sp_fosc_destroy(&fm->osc);
            sp_ftbl_destroy(&fm->ft);
            free(fm);
            break;
        default:
           plumber_print(pd,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}
