#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "plumber.h"

int sporth_gen_line(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    int size;
    sp_ftbl *ft;
    const char *str;
    const char *args;

    switch(pd->mode){
        case PLUMBER_CREATE:
#ifdef DEBUG_MODE
            plumber_print(pd, "gen_line: create mode\n");
#endif
            plumber_add_ugen(pd, SPORTH_GEN_LINE, NULL);
            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
                plumber_print(pd, "Init: not enough arguments for gen_line\n");
                return PLUMBER_NOTOK;
            }
            args = sporth_stack_pop_string(stack);
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
#ifdef DEBUG_MODE
            plumber_print(pd, "Creating line table %s of size %d\n", str, size);
#endif
            sp_ftbl_create(pd->sp, &ft, size);
            if(sp_gen_line(pd->sp, ft, args) == SP_NOT_OK) {
                plumber_print(pd, "There was an issue creating the line ftable \"%s\".\n", str);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            plumber_ftmap_add(pd, str, ft);
            break;

        case PLUMBER_INIT:

            args = sporth_stack_pop_string(stack);
            size = (int)sporth_stack_pop_float(stack);
            str = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;

        default:
           printf("Error: Unknown mode!");
           break;
    }
    return PLUMBER_OK;
}
