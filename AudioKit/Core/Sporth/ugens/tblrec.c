#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

int sporth_tblrec(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sp_tblrec *td;
    sp_ftbl *ft;
    const char *ftname;
    SPFLOAT trig = 0;
    SPFLOAT in = 0;
    SPFLOAT out = 0;

    switch(pd->mode){
        case PLUMBER_CREATE:
            sp_tblrec_create(&td);
            plumber_add_ugen(pd, SPORTH_TBLREC, td);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
               plumber_print(pd,"Init: not enough arguments for tblrec\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            trig = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            td->index = 0;
            td->record = 0;
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                plumber_print(pd, "tblrec: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sp_tblrec_init(pd->sp, td, ft);
            sporth_stack_push_float(stack, in);
            break;

        case PLUMBER_INIT:
            td = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);
            td->index = 0;
            td->record = 0;
            sporth_stack_push_float(stack, in);
            break;

        case PLUMBER_COMPUTE:
            td = pd->last->ud;
            trig = sporth_stack_pop_float(stack);
            in = sporth_stack_pop_float(stack);

            sp_tblrec_compute(pd->sp, td, &in, &trig, &out);
            sporth_stack_push_float(stack, out);

            break;

        case PLUMBER_DESTROY:
            td = pd->last->ud;
            sp_tblrec_destroy(&td);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}
