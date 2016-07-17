#include "plumber.h"

int sporth_tenv2(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT out;
    SPFLOAT atk;
    SPFLOAT rel;
    sp_tenv2 *tenv2;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "tenv2: Creating\n");
#endif

            sp_tenv2_create(&tenv2);
            plumber_add_ugen(pd, SPORTH_TENV2, tenv2);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for tenv2\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "tenv2: Initialising\n");
#endif

            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tenv2 = pd->last->ud;
            sp_tenv2_init(pd->sp, tenv2);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            rel = sporth_stack_pop_float(stack);
            atk = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            tenv2 = pd->last->ud;
            tenv2->atk = atk;
            tenv2->rel = rel;
            sp_tenv2_compute(pd->sp, tenv2, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tenv2 = pd->last->ud;
            sp_tenv2_destroy(&tenv2);
            break;
        default:
            fprintf(stderr, "tenv2: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
