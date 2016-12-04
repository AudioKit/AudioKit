#include "plumber.h"

int sporth_port(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT htime;
    SPFLOAT in = 0, out = 0;
    sp_port *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_port_create(&data);
            plumber_add_ugen(pd, SPORTH_PORT, data);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
               fprintf(stderr,"Not enough arguments for port\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            htime = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;

            htime = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            sp_port_init(pd->sp, data, htime);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            data = pd->last->ud;

            htime = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            data->htime = htime;

            sp_port_compute(pd->sp, data, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_port_destroy(&data);
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

int sporth_tport(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT htime;
    SPFLOAT in = 0, out = 0, trig = 0;
    sp_port *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_port_create(&data);
            plumber_add_ugen(pd, SPORTH_TPORT, data);
            if(sporth_check_args(stack, "fff") != SPORTH_OK) {
               fprintf(stderr,"Not enough arguments for port\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            htime = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;

            htime = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            sp_port_init(pd->sp, data, htime);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            data = pd->last->ud;

            htime = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            data->htime = htime;

            if(trig != 0) sp_port_reset(pd->sp, data, &in);
            sp_port_compute(pd->sp, data, &in, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_port_destroy(&data);
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
