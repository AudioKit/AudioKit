#include "plumber.h"

int sporth_rpt(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig;
    SPFLOAT input;
    SPFLOAT out;
    SPFLOAT maxdur;
    SPFLOAT bpm;
    int div;
    int rep;
    sp_rpt *rpt;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "rpt: Creating\n");
#endif

            sp_rpt_create(&rpt);
            plumber_add_ugen(pd, SPORTH_RPT, rpt);
            if(sporth_check_args(stack, "ffffff") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for rpt\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            maxdur = sporth_stack_pop_float(stack);
            rep = (int)sporth_stack_pop_float(stack);
            div = (int)sporth_stack_pop_float(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "rpt: Initialising\n");
#endif

            maxdur = sporth_stack_pop_float(stack);
            rep = (int)sporth_stack_pop_float(stack);
            div = (int)sporth_stack_pop_float(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            rpt = pd->last->ud;
            sp_rpt_init(pd->sp, rpt, maxdur);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            maxdur = sporth_stack_pop_float(stack);
            rep = (int)sporth_stack_pop_float(stack);
            div = (int)sporth_stack_pop_float(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            input = sporth_stack_pop_float(stack);
            rpt = pd->last->ud;
            rpt->bpm = bpm;
            rpt->div = div;
            rpt->rep = rep;
            sp_rpt_compute(pd->sp, rpt, &trig, &input, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            rpt = pd->last->ud;
            sp_rpt_destroy(&rpt);
            break;
        default:
            plumber_print(pd, "rpt: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
