#include <stdio.h>
#include <stdlib.h>
#include "plumber.h"

int sporth_nsmp(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT out = 0, trig = 0, index = 0, sr = 0;
    char *wav, *ini;
    sp_ftbl *ft;
    sp_nsmp *nsmp;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
           plumber_print(pd,"Creating nsmp function... \n");
#endif
            sp_nsmp_create(&nsmp);
            plumber_add_ugen(pd, SPORTH_NSMP, nsmp);
            if(sporth_check_args(stack, "fffss") != SPORTH_OK) {
                stack->error++;
                plumber_print(pd, "Invalid arguments for nsmp.\n");
                return PLUMBER_NOTOK;
            }

            wav = sporth_stack_pop_string(stack);
            ini = sporth_stack_pop_string(stack);
            sr = sporth_stack_pop_float(stack);
            index = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            if(plumber_ftmap_search(pd, wav, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            if(sp_nsmp_init(pd->sp, nsmp, ft, sr, ini) == SP_NOT_OK) {
                plumber_print(pd, "nsmp: there was an error opening the files\n");
                stack->error++;
                return PLUMBER_NOTOK;
            };
            sporth_stack_push_float(stack, 0.0);
            break;
        case PLUMBER_INIT:
            nsmp = pd->last->ud;

            wav = sporth_stack_pop_string(stack);
            ini = sporth_stack_pop_string(stack);
            sr = sporth_stack_pop_float(stack);
            index = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_COMPUTE:
            nsmp = pd->last->ud;
            sporth_stack_pop_float(stack);
            index = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            nsmp->index = (uint32_t) index;
            sp_nsmp_compute(pd->sp, nsmp, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            nsmp = pd->last->ud;
            sp_nsmp_destroy(&nsmp);
            break;
        default:
           plumber_print(pd,"Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}
