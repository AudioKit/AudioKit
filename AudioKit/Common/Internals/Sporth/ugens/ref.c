#include "plumber.h"
int sporth_ref(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    char *str;
    switch(pd->mode) {
        case PLUMBER_CREATE: 
            plumber_add_ugen(pd, SPORTH_REF, NULL);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                stack->error++;
                fprintf(stderr, "ref: Invalid arguments.");
                return PLUMBER_NOTOK;
            }
            sporth_stack_pop_string(stack);
            break;
        case PLUMBER_INIT: 
            str = sporth_stack_pop_string(stack);
            plumber_ftmap_delete(pd, 0);
            /* get reference of the *next* pipe in the plumbing */
            plumber_ftmap_add_userdata(pd, str, pd->next->ud);
            plumber_ftmap_delete(pd, 1);
            break;
        case PLUMBER_COMPUTE: 
            break;
        case PLUMBER_DESTROY: 
            break;
    }
    return PLUMBER_OK;
}
