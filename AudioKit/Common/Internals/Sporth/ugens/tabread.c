#include <stdlib.h>
#include <stdio.h>
#include "plumber.h"

int sporth_tabread(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    SPFLOAT out;
    char *ftname;
    sp_ftbl *ft;
    SPFLOAT index;
    SPFLOAT mode;
    SPFLOAT offset;
    SPFLOAT wrap;
    sp_tabread *tabread;

    switch(pd->mode) {
        case PLUMBER_CREATE:

#ifdef DEBUG_MODE
            fprintf(stderr, "tabread: Creating\n");
#endif

            sp_tabread_create(&tabread);
            plumber_add_ugen(pd, SPORTH_TABREAD, tabread);
            if(sporth_check_args(stack, "ffffs") != SPORTH_OK) {
                fprintf(stderr,"Not enough arguments for tabread\n");
                stack->error++;
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            wrap = sporth_stack_pop_float(stack);
            offset = sporth_stack_pop_float(stack);
            mode = sporth_stack_pop_float(stack);
            index = sporth_stack_pop_float(stack);

            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                stack->error++;
                return PLUMBER_NOTOK;
            }

            sp_tabread_init(pd->sp, tabread, ft, mode);
            sporth_stack_push_float(stack, 0);
            free(ftname);
            break;
        case PLUMBER_INIT:

#ifdef DEBUG_MODE
            fprintf(stderr, "tabread: Initialising\n");
#endif
            ftname = sporth_stack_pop_string(stack);
            wrap = sporth_stack_pop_float(stack);
            offset = sporth_stack_pop_float(stack);
            mode = sporth_stack_pop_float(stack);
            index = sporth_stack_pop_float(stack);
            tabread = pd->last->ud;

            sporth_stack_push_float(stack, 0);
            free(ftname);
            break;
        case PLUMBER_COMPUTE:
            wrap = sporth_stack_pop_float(stack);
            offset = sporth_stack_pop_float(stack);
            mode = sporth_stack_pop_float(stack);
            index = sporth_stack_pop_float(stack);
            tabread = pd->last->ud;
            tabread->index = index;
            tabread->mode = mode;
            tabread->offset = offset;
            tabread->wrap = wrap;
            sp_tabread_compute(pd->sp, tabread, NULL, &out);
            sporth_stack_push_float(stack, out);
            break;
        case PLUMBER_DESTROY:
            tabread = pd->last->ud;
            sp_tabread_destroy(&tabread);
            break;
        default:
            fprintf(stderr, "tabread: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
