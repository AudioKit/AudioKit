#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_load(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    plumbing *pipes;

    FILE *tmp, *fp;
    const char *filename;
    int rc = PLUMBER_OK;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_LOAD, NULL);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd, "Not enough arguments for load.\n");
                return PLUMBER_NOTOK;
            }

            filename = sporth_stack_pop_string(stack);
            fp = fopen(filename, "r");
            if(fp == NULL) {
                plumber_print(pd, 
                        "There was an issue opening the file \"%s\"\n",
                        filename);
                return PLUMBER_NOTOK;
            }
            tmp = pd->fp;
            pd->fp = fp;
            pipes = plumber_get_pipes(pd);
            rc = plumbing_parse(pd, pipes);
            fclose(fp);
            pd->fp = tmp;
            return rc;

        case PLUMBER_INIT:
            filename = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
