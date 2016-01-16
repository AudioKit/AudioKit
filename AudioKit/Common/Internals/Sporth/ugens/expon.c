#include <stdlib.h>
#include <math.h>
#include "plumber.h"

int sporth_expon(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT ia = 0;
    SPFLOAT idur = 0;
    SPFLOAT ib = 0;
    SPFLOAT out = 0;
    sp_expon *expon;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "expon: Creating\n");
#endif
            sp_expon_create(&expon);
            plumber_add_ugen(pd, SPORTH_EXPON, expon);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for expon\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ib = sporth_stack_pop_float(stack);
            idur = sporth_stack_pop_float(stack);
            ia = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "expon: Initialising\n");
#endif

            expon = pd->last->ud;
            ib = sporth_stack_pop_float(stack);
            idur = sporth_stack_pop_float(stack);
            ia = sporth_stack_pop_float(stack);
            sp_expon_init(pd->sp, expon, ia, idur, ib);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            expon = pd->last->ud;
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sp_expon_compute(pd->sp, expon, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            expon = pd->last->ud;
            sp_expon_destroy(&expon);
            break;
        default:
            fprintf(stderr, "expon: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
