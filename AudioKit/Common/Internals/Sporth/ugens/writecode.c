#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_writecode(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    const char *file;
    FILE *fp;
    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_WRITECODE, NULL);

            if(sporth_check_args(stack, "s") != SPORTH_OK) {
                plumber_print(pd, "writecode: not enough arguments\n");
                return PLUMBER_NOTOK;
            }

            file = sporth_stack_pop_string(stack);
            fp = fopen(file, "w");
            if(fp == NULL) {
                plumber_print(pd, "There was a problem opening %s", file);
                return PLUMBER_NOTOK;
            }
            plumber_write_code(pd, fp);
            fclose(fp);
            
            break;

        case PLUMBER_INIT:
            sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           break;
    }
    return PLUMBER_OK;
}
