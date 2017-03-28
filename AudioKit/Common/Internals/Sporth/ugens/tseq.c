#include <stdio.h>
#include <stdlib.h>
#include "plumber.h"

int sporth_tseq(sporth_stack *stack, void *ud)
{
    if(stack->error > 0) return PLUMBER_NOTOK;

    plumber_data *pd = ud;
    SPFLOAT out = 0, trig = 0, shuf = 0;
    char *ftname;
    sp_ftbl *ft;
    sp_tseq *tseq;

    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "Creating tseq function... \n");
#endif
            sp_tseq_create(&tseq);
            plumber_add_ugen(pd, SPORTH_TSEQ, tseq);

            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
                stack->error++;
                plumber_print(pd, "Invalid arguments for tseq.\n");
                return PLUMBER_NOTOK;
            }

            ftname = sporth_stack_pop_string(stack);
            shuf = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0.0);

            break;
        case PLUMBER_INIT:

            ftname = sporth_stack_pop_string(stack);
            shuf = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

#ifdef DEBUG_MODE
            plumber_print(pd, "tseq INIT: searching for ftable... \n");
#endif

            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            tseq = pd->last->ud;
            sp_tseq_init(pd->sp, tseq, ft);
            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_COMPUTE:
            tseq = pd->last->ud;
            shuf = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);

            tseq->shuf = shuf;
            sp_tseq_compute(pd->sp, tseq, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
#ifdef DEBUG_MODE
            plumber_print(pd, "Destroying tseq\n");
#endif 
            tseq = pd->last->ud;
            sp_tseq_destroy(&tseq);
            break;
        default:
            printf("Error: Unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}
