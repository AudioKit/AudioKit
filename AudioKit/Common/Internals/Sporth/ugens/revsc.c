#include "plumber.h"

int sporth_revsc(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT in1, in2, feedback, lpfreq;

    SPFLOAT out1 = 0, out2 = 0;
    sp_revsc *data;

    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_revsc_create(&data);
            plumber_add_ugen(pd, SPORTH_REVSC, data);
            if(sporth_check_args(stack, "ffff") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for revsc!\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            lpfreq = sporth_stack_pop_float(stack);
            feedback = sporth_stack_pop_float(stack);
            in2 = sporth_stack_pop_float(stack);
            in1 = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;

        case PLUMBER_INIT:
            data = pd->last->ud;

            lpfreq = sporth_stack_pop_float(stack);
            feedback = sporth_stack_pop_float(stack);
            in2 = sporth_stack_pop_float(stack);
            in1 = sporth_stack_pop_float(stack);

            sp_revsc_init(pd->sp, data);

            sporth_stack_push_float(stack, 0);
            sporth_stack_push_float(stack, 0);
            break;

        case PLUMBER_COMPUTE:
            data = pd->last->ud;

            lpfreq = sporth_stack_pop_float(stack);
            feedback = sporth_stack_pop_float(stack);
            in2 = sporth_stack_pop_float(stack);
            in1 = sporth_stack_pop_float(stack);


            data->feedback = feedback;
            data->lpfreq = lpfreq;
            out1 = 0; out2 = 0;
            sp_revsc_compute(pd->sp, data, &in1, &in2, &out1, &out2);

            sporth_stack_push_float(stack, out1);
            sporth_stack_push_float(stack, out2);

            break;

        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_revsc_destroy(&data);
            break;

        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
