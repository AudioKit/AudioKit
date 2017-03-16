#include "plumber.h"

int sporth_rspline(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    SPFLOAT min;
    SPFLOAT max;
    SPFLOAT cps_min;
    SPFLOAT cps_max;
    sp_rspline *rspline;

    switch(pd->mode) {
        case PLUMBER_CREATE:
            sp_rspline_create(&rspline);
            plumber_add_ugen(pd, SPORTH_RSPLINE, rspline);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for rspline\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            cps_max = sporth_stack_pop_float(stack);
            cps_min = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            cps_max = sporth_stack_pop_float(stack);
            cps_min = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            rspline = pd->last->ud;
            sp_rspline_init(pd->sp, rspline);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            cps_max = sporth_stack_pop_float(stack);
            cps_min = sporth_stack_pop_float(stack);
            max = sporth_stack_pop_float(stack);
            min = sporth_stack_pop_float(stack);
            rspline = pd->last->ud;
            rspline->min = min;
            rspline->max = max;
            rspline->cps_min = cps_min;
            rspline->cps_max = cps_max;
            sp_rspline_compute(pd->sp, rspline, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            rspline = pd->last->ud;
            sp_rspline_destroy(&rspline);
            break;
    }
    return PLUMBER_OK;
}
