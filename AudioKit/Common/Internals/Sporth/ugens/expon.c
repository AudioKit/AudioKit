#include <stdlib.h>
#include <math.h>
#include "plumber.h"

typedef struct {
    SPFLOAT ia, idur, ib;
    SPFLOAT val, incr; 
} sporth_expon_d;

static void expon_init(plumber_data *pd, sporth_expon_d *expon)
{
    SPFLOAT onedsr = 1.0 / pd->sp->sr;
    if((expon->ia * expon->ib) > 0.0) {
        expon->incr = pow((SPFLOAT)(expon->ib / expon->ia), onedsr / expon->idur);
    } else {
        expon->incr = 1;
    }
    expon->val = expon->ia;
}

SPFLOAT expon_compute(sporth_expon_d *expon) 
{
    SPFLOAT val = expon->val;
    expon->val *= expon->incr;
    return val;
}

int sporth_expon(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    
    sporth_expon_d *expon;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "expon: Creating\n");
#endif
            expon = malloc(sizeof(sporth_expon_d));
            plumber_add_module(pd, SPORTH_EXPON, sizeof(sporth_expon_d), expon);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "expon: Initialising\n");
#endif

            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for expon\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            expon = pd->last->ud;
            expon->ib = sporth_stack_pop_float(stack);
            expon->idur = sporth_stack_pop_float(stack);
            expon->ia = sporth_stack_pop_float(stack);
            expon_init(pd, expon);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            expon = pd->last->ud;
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, expon_compute(expon));
            break;
        case PLUMBER_DESTROY:
            expon = pd->last->ud;
            free(expon);
            break;
        default:
            fprintf(stderr, "expon: Uknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
