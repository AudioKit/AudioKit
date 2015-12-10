#include <stdio.h>
#include <stdlib.h>
#include "plumber.h"

typedef struct {
    SPFLOAT trigger;
    SPFLOAT excite;
    SPFLOAT ifreq;
    sp_pluck *pluck;
    sp_ftbl *ft;
    sp_osc *exc;
} sporth_pluck_d;


int sporth_pluck(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_pluck_d *pluck;
    SPFLOAT exc = 0, out = 0;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "pluck: Creating\n");
#endif
            pluck = malloc(sizeof(sporth_pluck_d));
            sp_pluck_create(&pluck->pluck);
            sp_ftbl_create(pd->sp, &pluck->ft, 4096);
            sp_osc_create(&pluck->exc);
            plumber_add_ugen(pd, SPORTH_PLUCK, pluck);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "pluck: Initialising\n");
#endif

            if(sporth_check_args(stack, "fffffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for pluck\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            pluck = pd->last->ud;

            pluck->ifreq = sporth_stack_pop_float(stack);
            pluck->pluck->reflect = sporth_stack_pop_float(stack);
            pluck->pluck->pick = sporth_stack_pop_float(stack);
            pluck->pluck->amp = sporth_stack_pop_float(stack);
            pluck->pluck->freq = sporth_stack_pop_float(stack);
            pluck->pluck->plk = sporth_stack_pop_float(stack);
            pluck->trigger = sporth_stack_pop_float(stack);

            sp_gen_sine(pd->sp, pluck->ft);
            sp_osc_init(pd->sp, pluck->exc, pluck->ft, 0);
            pluck->exc->freq = 1;
            pluck->exc->amp = 1;
            sp_pluck_init(pd->sp, pluck->pluck, pluck->ifreq);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "fffffff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for pluck\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            pluck = pd->last->ud;
            pluck->ifreq = sporth_stack_pop_float(stack);
            pluck->pluck->reflect = sporth_stack_pop_float(stack);
            pluck->pluck->pick = sporth_stack_pop_float(stack);
            pluck->pluck->amp = sporth_stack_pop_float(stack);
            pluck->pluck->freq = sporth_stack_pop_float(stack);
            pluck->pluck->plk = sporth_stack_pop_float(stack);
            pluck->trigger = sporth_stack_pop_float(stack);

            sp_osc_compute(pd->sp, pluck->exc, NULL, &exc);
            sp_pluck_compute(pd->sp, pluck->pluck, &pluck->trigger, &exc, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            pluck = pd->last->ud;
            sp_pluck_destroy(&pluck->pluck);
            sp_ftbl_destroy(&pluck->ft);
            sp_osc_destroy(&pluck->exc);
            free(pluck);
            break;
        default:
            fprintf(stderr, "pluck: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
