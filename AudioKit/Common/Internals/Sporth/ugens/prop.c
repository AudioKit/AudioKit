#include <stdio.h>
#include <stdlib.h>

#include "plumber.h"

int sporth_prop(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT bpm;
    SPFLOAT out;
    sp_prop *data;
    char *str;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_prop_create(&data);
            plumber_add_ugen(pd, SPORTH_PROP, data);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
                fprintf(stderr, "Not enough arguments for prop\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            bpm = sporth_stack_pop_float(stack);
            if(sp_prop_init(pd->sp, data, str) == SP_NOT_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;
            str = sporth_stack_pop_string(stack);
            bpm = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            bpm = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            data->bpm = bpm;
            sp_prop_compute(pd->sp, data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_prop_destroy(&data);
            break;
        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}

/* tprop is almost identical to prop, except that a trigger can reset it */
int sporth_tprop(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT bpm;
    SPFLOAT out;
    SPFLOAT trig;
    sp_prop *data;
    char *str;
    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_prop_create(&data);
            plumber_add_ugen(pd, SPORTH_TPROP, data);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
                fprintf(stderr, "Not enough arguments for tprop\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            if(sp_prop_init(pd->sp, data, str) == SP_NOT_OK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            data = pd->last->ud;
            str = sporth_stack_pop_string(stack);
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            bpm = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            data = pd->last->ud;
            data->bpm = bpm;
            if(trig != 0) {
                sp_prop_reset(pd->sp, data);
            }
            sp_prop_compute(pd->sp, data, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            sp_prop_destroy(&data);
            break;
        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
