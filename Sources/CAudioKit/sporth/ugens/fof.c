#include <stdlib.h>
#include "plumber.h"

int sporth_fof(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    sp_ftbl *sine;
    sp_ftbl *win;

    const char *sinestr, *winstr;

    int iolaps;
    SPFLOAT iphs;
    SPFLOAT amp;
    SPFLOAT fund;
    SPFLOAT form;
    SPFLOAT oct;
    SPFLOAT band;
    SPFLOAT ris;
    SPFLOAT dec;
    SPFLOAT dur;
    sp_fof *fof;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "fof: Creating\n");
#endif

            sp_fof_create(&fof);
            plumber_add_ugen(pd, SPORTH_FOF, fof);
            if(sporth_check_args(stack, "ffffffffffss") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fof\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sinestr = sporth_stack_pop_string(stack);
            winstr = sporth_stack_pop_string(stack);
            iolaps = sporth_stack_pop_float(stack);
            iphs = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            ris = sporth_stack_pop_float(stack);
            band = sporth_stack_pop_float(stack);
            oct = sporth_stack_pop_float(stack);
            form = sporth_stack_pop_float(stack);
            fund = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "fof: Initialising\n");
#endif

            sinestr = sporth_stack_pop_string(stack);
            winstr = sporth_stack_pop_string(stack);
            iolaps = sporth_stack_pop_float(stack);
            iphs = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            ris = sporth_stack_pop_float(stack);
            band = sporth_stack_pop_float(stack);
            oct = sporth_stack_pop_float(stack);
            form = sporth_stack_pop_float(stack);
            fund = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            fof = pd->last->ud;

            if(plumber_ftmap_search(pd, sinestr, &sine) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            if(plumber_ftmap_search(pd, winstr, &win) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            sp_fof_init(pd->sp, fof, sine, win, iolaps, iphs);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            iolaps = sporth_stack_pop_float(stack);
            iphs = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            ris = sporth_stack_pop_float(stack);
            band = sporth_stack_pop_float(stack);
            oct = sporth_stack_pop_float(stack);
            form = sporth_stack_pop_float(stack);
            fund = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            fof = pd->last->ud;
            fof->amp = amp;
            fof->fund = fund;
            fof->form = form;
            fof->oct = oct;
            fof->band = band;
            fof->ris = ris;
            fof->dec = dec;
            fof->dur = dur;
            sp_fof_compute(pd->sp, fof, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            fof = pd->last->ud;
            sp_fof_destroy(&fof);
            break;
        default:
            plumber_print(pd, "fof: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
