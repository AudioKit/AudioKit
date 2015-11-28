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
            plumber_add_module(pd, SPORTH_PORT, sizeof(sp_port), data);
            break;
        case PLUMBER_INIT:
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
               fprintf(stderr,"Not enough arguments for port\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            data = pd->last->ud;

            htime = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            sp_port_init(pd->sp, data, htime);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
               fprintf(stderr,"Not enough arguments for port\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
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
    return PLUMBER_NOTOK;
}
