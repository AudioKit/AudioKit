#include <math.h>
#include "plumber.h"

int plumber_set_var(plumber_data *pd, char *name, SPFLOAT *var);

int sporth_p(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    int n;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "p: creating\n");
#endif
            plumber_add_ugen(pd, SPORTH_P, NULL);

            if(sporth_check_args(stack, "f") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for P\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }

            n = (int)sporth_stack_pop_float(stack);
            if(n < 16)
                sporth_stack_push_float(stack, pd->p[n]);
            else
                sporth_stack_push_float(stack, 0);

            break;
        case PLUMBER_INIT:
            n = (int)sporth_stack_pop_float(stack);

            if(n < 16)
                sporth_stack_push_float(stack, pd->p[n]);
            else
                sporth_stack_push_float(stack, 0);
            break;
        case PLUMBER_COMPUTE:
            n = (int)sporth_stack_pop_float(stack);
            if(n < 16)
                sporth_stack_push_float(stack, pd->p[n]);
            else
                sporth_stack_push_float(stack, 0);

            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd, "switch: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_pset(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    int n;
    SPFLOAT val;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "p: creating\n");
#endif

            plumber_add_ugen(pd, SPORTH_PSET, NULL);
            if(sporth_check_args(stack, "ff") != SPORTH_OK) {
                plumber_print(pd,"Pset: Not enough arguments\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            n = (int)sporth_stack_pop_float(stack);
            val = sporth_stack_pop_float(stack);
            if(n < 16) pd->p[n] = val;
            break;
        case PLUMBER_INIT:
            sporth_stack_pop_float(stack);
            sporth_stack_pop_float(stack);
            break;
        case PLUMBER_COMPUTE:
            n = (int)sporth_stack_pop_float(stack);
            val = sporth_stack_pop_float(stack);
            if(n < 16) pd->p[n] = val;

            break;
        case PLUMBER_DESTROY:
            break;
        default:
            plumber_print(pd, "pset: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

int sporth_palias(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    char *name;
    int id;
    SPFLOAT *foo;

    switch(pd->mode) {
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_PALIAS, NULL);
            if(sporth_check_args(stack, "sf") != SPORTH_OK) {
                plumber_print(pd,"palias: Not enough arguments\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            id = floor(sporth_stack_pop_float(stack));
            name = sporth_stack_pop_string(stack);
            foo = &pd->p[id];
            plumber_ftmap_delete(pd, 0);
            plumber_set_var(pd, name, foo);
            plumber_ftmap_delete(pd, 1);
            break;
        case PLUMBER_INIT:
            sporth_stack_pop_float(stack);
            sporth_stack_pop_string(stack);
            break;
        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;
        default:
            break;
    }

    return PLUMBER_OK;
}
