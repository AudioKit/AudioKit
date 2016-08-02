#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

typedef struct {
    int init;
    char label[128];
    SPFLOAT pval;
} sporth_print_d;


int sporth_print(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_print_d *prnt;
    char *str = NULL; 
    SPFLOAT val = 0;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "print: Creating\n");
#endif
            prnt = malloc(sizeof(sporth_print_d));
            plumber_add_ugen(pd, SPORTH_PRINT, prnt);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for print\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            str = sporth_stack_pop_string(stack);
            val = sporth_stack_pop_float(stack);
            
            strncpy(prnt->label, str, 128);
            prnt->pval = val; 
            prnt->init = 1;
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "print: Initialising\n");
#endif
            prnt = pd->last->ud;
            str = sporth_stack_pop_string(stack);
            val = sporth_stack_pop_float(stack);
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_COMPUTE:
            prnt = pd->last->ud;
            val = sporth_stack_pop_float(stack);
            if(val != prnt->pval || prnt->init) {
                prnt->pval = val;
                prnt->init = 0;
                printf("%s: %g\n", prnt->label, val);
            }
            sporth_stack_push_float(stack, val);
            break;
        case PLUMBER_DESTROY:
            prnt = pd->last->ud;
            free(prnt);
            break;
        default:
            fprintf(stderr, "print: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
