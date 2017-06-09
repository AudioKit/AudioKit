#include <stdlib.h>
#include "plumber.h"

int sporth_fog(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    const char *wavstr, *winstr;
    sp_ftbl *wav;
    sp_ftbl *win;
    int iolaps;
    SPFLOAT iphs;
    SPFLOAT amp;
    SPFLOAT dense;
    SPFLOAT trans;
    SPFLOAT spd;
    SPFLOAT oct;
    SPFLOAT band;
    SPFLOAT ris;
    SPFLOAT dec;
    SPFLOAT dur;
    sp_fog *fog;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "fog: Creating\n");
#endif

            sp_fog_create(&fog);
            plumber_add_ugen(pd, SPORTH_FOG, fog);
            if(sporth_check_args(stack, "fffffffffffss") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for fog\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            wavstr = sporth_stack_pop_string(stack);
            winstr = sporth_stack_pop_string(stack);
            iolaps = sporth_stack_pop_float(stack);
            iphs = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            ris = sporth_stack_pop_float(stack);
            band = sporth_stack_pop_float(stack);
            oct = sporth_stack_pop_float(stack);
            spd = sporth_stack_pop_float(stack);
            trans = sporth_stack_pop_float(stack);
            dense = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "fog: Initialising\n");
#endif

            wavstr = sporth_stack_pop_string(stack);
            winstr = sporth_stack_pop_string(stack);
            iolaps = sporth_stack_pop_float(stack);
            iphs = sporth_stack_pop_float(stack);
            dur = sporth_stack_pop_float(stack);
            dec = sporth_stack_pop_float(stack);
            ris = sporth_stack_pop_float(stack);
            band = sporth_stack_pop_float(stack);
            oct = sporth_stack_pop_float(stack);
            spd = sporth_stack_pop_float(stack);
            trans = sporth_stack_pop_float(stack);
            dense = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            fog = pd->last->ud;

            if(plumber_ftmap_search(pd, wavstr, &wav) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            if(plumber_ftmap_search(pd, winstr, &win) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            sp_fog_init(pd->sp, fog, wav, win, iolaps, iphs);

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
            spd = sporth_stack_pop_float(stack);
            trans = sporth_stack_pop_float(stack);
            dense = sporth_stack_pop_float(stack);
            amp = sporth_stack_pop_float(stack);
            fog = pd->last->ud;
            fog->amp = amp;
            fog->dens = dense;
            fog->trans = trans;
            fog->spd = spd;
            fog->oct = oct;
            fog->band = band;
            fog->ris = ris;
            fog->dec = dec;
            fog->dur = dur;
            sp_fog_compute(pd->sp, fog, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            fog = pd->last->ud;
            sp_fog_destroy(&fog);
            break;
        default:
            plumber_print(pd, "fog: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
