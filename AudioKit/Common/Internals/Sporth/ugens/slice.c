#include "plumber.h"

int sporth_slice(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    char *vals_name;
    char *buf_name;
    SPFLOAT trig;
    SPFLOAT out;
    sp_ftbl * vals;
    sp_ftbl * buf;
    SPFLOAT id;
    sp_slice *slice;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "slice: Creating\n");
#endif

            sp_slice_create(&slice);
            plumber_add_ugen(pd, SPORTH_SLICE, slice);
            if(sporth_check_args(stack, "ffss") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for slice\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            buf_name = sporth_stack_pop_string(stack);
            vals_name = sporth_stack_pop_string(stack);
            id = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "slice: Initialising\n");
#endif

            buf_name = sporth_stack_pop_string(stack);
            vals_name = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search(pd, vals_name, &vals) == PLUMBER_NOTOK) { 
                plumber_print(pd, "slice: could not find ftable %s\n", 
                    vals_name);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            
            if(plumber_ftmap_search(pd, buf_name, &buf) == PLUMBER_NOTOK) { 
                plumber_print(pd, "slice: could not find ftable %s\n", 
                    vals_name);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            id = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            slice = pd->last->ud;
            sp_slice_init(pd->sp, slice, vals, buf);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            id = sporth_stack_pop_float(stack);
            trig = sporth_stack_pop_float(stack);
            slice = pd->last->ud;
            slice->id = id;
            sp_slice_compute(pd->sp, slice, &trig, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            slice = pd->last->ud;
            sp_slice_destroy(&slice);
            break;
        default:
            plumber_print(pd, "slice: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
