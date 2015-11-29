#include <stdlib.h>
#include "plumber.h"

int sporth_f(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    unsigned int fnum;
    sporth_func_d *fd;
    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "aux (f)unction: creating\n");
#endif
            fd = malloc(sizeof(sporth_func_d));
            plumber_add_module(pd, SPORTH_F, sizeof(sporth_func_d), fd);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "aux (f)unction: initialising\n");
#endif
           if(sporth_check_args(stack, "f") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for aux (f)unction\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            fnum = (int)sporth_stack_pop_float(stack);

            if(fnum > 16) {
                fprintf(stderr, "Invalid function number %d\n", fnum);
                stack->error++;
                return PLUMBER_NOTOK;
            }

            fd = pd->last->ud;
            fd->fun = pd->f[fnum];

            pd->mode = PLUMBER_CREATE;
            fd->fun(stack, ud);

            pd->mode = PLUMBER_INIT;
            fd->fun(stack, ud);

            break;

        case PLUMBER_COMPUTE:
            fnum = (int)sporth_stack_pop_float(stack);
            fd = pd->last->ud;
            fd->fun(stack, ud);
            break;

        case PLUMBER_DESTROY:
            fd = pd->last->ud;
            fd->fun(stack, ud);
            free(fd);
            break;
        default:
            fprintf(stderr, "aux (f)unction: unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

