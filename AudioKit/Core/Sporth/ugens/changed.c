#include <stdlib.h>
#include "plumber.h"

int sporth_changed(sporth_stack *stack, void *ud)
{
    plumber_data *pd = (plumber_data *)ud;
    SPFLOAT *prev;
    SPFLOAT val;

    switch(pd->mode) {
        case PLUMBER_CREATE:
            prev = malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_CHANGED, prev);
            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                stack->error++;
                plumber_print(pd, "Invalid arguments for changed\n");
                return PLUMBER_NOTOK;
            }
            sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_INIT:
            sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            prev = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            if(val != *prev) {
                sporth_stack_push_float(stack, 1);
            } else {
                sporth_stack_push_float(stack, 0);
            }
            *prev = val;
            break;
        case PLUMBER_DESTROY:
            prev = pd->last->ud;
            free(prev);
            break;
    }
    return PLUMBER_OK;
}
