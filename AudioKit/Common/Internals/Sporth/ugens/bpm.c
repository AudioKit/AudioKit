#include <stdlib.h>
#include "plumber.h"

typedef struct {
    SPFLOAT pbpm;
    SPFLOAT val;
} bpm2val;


int sporth_bpm2dur(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    bpm2val *data;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "bpm2dur: Creating\n");
#endif
            data = malloc(sizeof(bpm2val));
            data->pbpm = -100;
            data->val= -100;
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr, "bpm2dur: not enough args\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            data->pbpm= val;
            data->val= 60.0 / val;
            plumber_add_ugen(pd, SPORTH_BPM2DUR, data);
            sporth_stack_push_float(stack, data->val);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "bpm2dur: Initializing\n");
#endif
            data = pd->last->ud;
            val = sporth_stack_pop_float(stack);

            if(data->pbpm != val) {
                data->pbpm= val;
                data->val= 60.0 / val;
            }

            sporth_stack_push_float(stack, data->val);
            break;
        case PLUMBER_COMPUTE:
            data = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            if(data->pbpm  != val) {
                data->pbpm= val;
                data->val = 60.0 / val;
            }
            sporth_stack_push_float(stack, data->val);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            free(data);
            break;
        default:
            fprintf(stderr,"bpm2dur: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}

int sporth_bpm2rate(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    bpm2val *data;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            fprintf(stderr, "bpm2rate: Creating\n");
#endif
            data = malloc(sizeof(bpm2val));
            data->pbpm = -100;
            data->val= -100;
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr, "bpm2rate: not enough args\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            data->pbpm= val;
            data->val= val / 60.0;
            plumber_add_ugen(pd, SPORTH_BPM2RATE, data);
            sporth_stack_push_float(stack, data->val);
            break;
        case PLUMBER_INIT:
#ifdef DEBUG_MODE
            fprintf(stderr, "bpm2rate: Initializing\n");
#endif
            data = pd->last->ud;
            val = sporth_stack_pop_float(stack);

            if(data->pbpm != val) {
                data->pbpm= val;
                data->val = val / 60.0;
            }

            sporth_stack_push_float(stack, data->val);
            break;
        case PLUMBER_COMPUTE:
            data = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            if(data->pbpm  != val) {
                data->pbpm= val;
                data->val = val / 60.0;
            }
            sporth_stack_push_float(stack, data->val);
            break;
        case PLUMBER_DESTROY:
            data = pd->last->ud;
            free(data);
            break;
        default:
            fprintf(stderr,"bpm2rate: unknown mode!");
            stack->error++;
            return PLUMBER_NOTOK;
            break;
    }
    return PLUMBER_OK;
}
