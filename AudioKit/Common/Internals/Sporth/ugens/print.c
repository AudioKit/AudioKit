#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

typedef struct {
    int init;
    int type;
    char label[128];
    SPFLOAT pval;
    char *sval;
} sporth_print_d;


int sporth_prints(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_print_d *prnt;
    char *str = NULL; 
    SPFLOAT val = 0;
    char *sval = NULL;
    sporth_stack_val *stackval; 
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            plumber_print(pd, "print: Creating\n");
#endif
            prnt = malloc(sizeof(sporth_print_d));
            plumber_add_ugen(pd, SPORTH_PRINT, prnt);
            if(sporth_check_args(stack, "ns") != SPORTH_OK) {
                plumber_print(pd,"Not enough arguments for print\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            stackval = sporth_stack_get_last(stack);
            prnt->type = stackval->type;

            if(prnt->type == SPORTH_FLOAT) {
                val = sporth_stack_pop_float(stack);
                prnt->pval = val; 
                plumber_print(pd, "%s: \"%g\",\n", str, val);
                sporth_stack_push_float(stack, val);
            } else if(prnt->type == SPORTH_STRING) {
                sval = sporth_stack_pop_string(stack);
                prnt->sval = sval;
                plumber_print(pd, "%s: \"%s\",\n", str, prnt->sval); 
                sporth_stack_push_string(stack, &sval);
            } else {
                plumber_print(pd, "Print: unknown type\n");
                return PLUMBER_NOTOK;
            }
            
            strncpy(prnt->label, str, 128);
            prnt->init = 1;
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            plumber_print(pd, "print: Initialising\n");
#endif
            prnt = pd->last->ud;
            str = sporth_stack_pop_string(stack);

            if(prnt->type == SPORTH_FLOAT) {
                val = sporth_stack_pop_float(stack);
                sporth_stack_push_float(stack, val);
            } else if(prnt->type == SPORTH_STRING) {
                sval = sporth_stack_pop_string(stack);
                sporth_stack_push_string(stack, &sval);
            }

            break;
        case PLUMBER_COMPUTE:
            prnt = pd->last->ud;
            if(prnt->type == SPORTH_FLOAT) {
                val = sporth_stack_pop_float(stack);
                if(val != prnt->pval && prnt->init == 0) {
                    prnt->pval = val;
                    plumber_print(pd, "%s: \"%g\",\n", prnt->label, val);
                }
                prnt->init = 0;
                sporth_stack_push_float(stack, val);
            } 
            break;
        case PLUMBER_DESTROY:
            prnt = pd->last->ud;
            free(prnt);
            break;
        default:
            plumber_print(pd, "print: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
