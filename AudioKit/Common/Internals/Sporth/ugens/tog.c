#include <stdlib.h>
#include "plumber.h"


int sporth_tog(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT trig = 0;
    SPFLOAT *val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            val = malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_TOG, val);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                plumber_print(pd,"Invalid arguments for tog.\n");
                return PLUMBER_NOTOK;
            }

            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            val = pd->last->ud;
            trig = sporth_stack_pop_float(stack);

            *val = 0;
            sporth_stack_push_float(stack, *val);
            break;
        case PLUMBER_COMPUTE:
            val = pd->last->ud;
            trig = sporth_stack_pop_float(stack);
            if(trig != 0) {
                *val = (*val == 0) ? 1 : 0;
            } 
            sporth_stack_push_float(stack, *val);
            break;
        case PLUMBER_DESTROY:
            val = pd->last->ud;
            free(val);
            break;
        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
