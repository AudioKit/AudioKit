#include "plumber.h"

int sporth_metro(sporth_stack *stack, void *ud) 
{
    plumber_data *pd = ud;

    SPFLOAT freq;
    SPFLOAT out;
    sp_metro *data;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_metro_create(&data);
            plumber_add_module(pd, SPORTH_METRO, sizeof(sp_metro), data);
            break;
        case PLUMBER_INIT:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
               fprintf(stderr,"Not enough arguments for metro\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            data = pd->last->ud;
            freq = sporth_stack_pop_float(stack);
            sp_metro_init(pd->sp, data);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
               fprintf(stderr,"Not enough arguments for metro\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            freq = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            data->freq = freq;
            sp_metro_compute(pd->sp, data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_metro_destroy(&data);
            break;
        default:
          fprintf(stderr,"Error: Unknown mode!"); 
           break;
    }   
    return PLUMBER_NOTOK;
}
