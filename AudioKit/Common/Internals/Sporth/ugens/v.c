#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"


int sporth_get(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    SPFLOAT **var;
    switch(pd->mode){
        case PLUMBER_CREATE:
            var = malloc(sizeof(SPFLOAT *));
            plumber_add_ugen(pd, SPORTH_GET, var);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               plumber_print(pd,"Not enough arguments for get\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search_userdata(pd, ftname, (void **)var) == PLUMBER_NOTOK) {
                plumber_print(pd, "get: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, **var);
            break;

        case PLUMBER_INIT:
            var = pd->last->ud;
            sporth_stack_pop_string(stack);
            sporth_stack_push_float(stack, **var);
            break;

        case PLUMBER_COMPUTE:
            var = pd->last->ud;
            sporth_stack_push_float(stack, **var);
            break;

        case PLUMBER_DESTROY:
            var = pd->last->ud;
            free(var);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_set(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    SPFLOAT **var;
    SPFLOAT val;
    switch(pd->mode){
        case PLUMBER_CREATE:
            var = malloc(sizeof(SPFLOAT *));
            plumber_add_ugen(pd, SPORTH_SET, var);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
               plumber_print(pd,"Not enough arguments for get\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            val = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search_userdata(pd, ftname, (void **)var) == PLUMBER_NOTOK) {
                plumber_print(pd, "set: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            **var = val;
            break;

        case PLUMBER_INIT:
            var = pd->last->ud;
            sporth_stack_pop_string(stack);
            val = sporth_stack_pop_float(stack);
            **var = val;
            break;

        case PLUMBER_COMPUTE:
            var = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            **var = val;
            break;

        case PLUMBER_DESTROY:
            var = pd->last->ud;
            free(var);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_var(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT *var;
    char *str;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_VAR, NULL);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd, "Init: not enough arguments for var\n");
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
#ifdef DEBUG_MODE
            plumber_print(pd, "var: creating table %s\n", str);
#endif
            var = malloc(sizeof(SPFLOAT));
            *var = 0;
            plumber_ftmap_add_userdata(pd, str, var);
            break;

        case PLUMBER_INIT:
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           plumber_print(pd, "Error: Unknown mode!\n");
           break;
    }
    return PLUMBER_OK;
}

int sporth_varset(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    SPFLOAT *var;
    SPFLOAT val;
    char *str;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_VARSET, NULL);
            if(sporth_check_args(stack, "sf") != SPORTH_OK) {
                plumber_print(pd, "Init: not enough arguments for varset\n");
                return PLUMBER_NOTOK;
            }
            val = sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
#ifdef DEBUG_MODE
            plumber_print(pd, "var: creating table %s\n", str);
#endif
            var = malloc(sizeof(SPFLOAT));
            *var = val;
            plumber_ftmap_add_userdata(pd, str, var);
            break;

        case PLUMBER_INIT:
            sporth_stack_pop_float(stack);
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           plumber_print(pd, "Error: Unknown mode!\n");
           break;
    }
    return PLUMBER_OK;
}

int plumber_create_var(plumber_data *pd, char *name, SPFLOAT **var)
{
    SPFLOAT *ptr = malloc(sizeof(SPFLOAT));
    plumber_ftmap_add_userdata(pd, name, ptr);
    *var = ptr;
    return PLUMBER_OK;
}

int plumber_set_var(plumber_data *pd, char *name, SPFLOAT *var)
{
    plumber_ftmap_add_userdata(pd, name, var);
    return PLUMBER_OK;
}
