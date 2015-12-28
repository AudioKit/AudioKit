#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

typedef struct {
    sp_ftbl *ft;
    SPFLOAT val;
    unsigned int index;
    int record;
} sporth_tbl_d;

int sporth_tblrec(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;
    sporth_tbl_d *td;
    char *ftname;
    SPFLOAT trig = 0;

    switch(pd->mode){
        case PLUMBER_CREATE:
            td = malloc(sizeof(sporth_tbl_d));
            plumber_add_ugen(pd, SPORTH_TBLREC, td);
            break;

        case PLUMBER_INIT:
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for tblrec\n");
                return PLUMBER_NOTOK;
            }
            td = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            trig = sporth_stack_pop_float(stack);
            td->val = sporth_stack_pop_float(stack);
            td->index = 0;
            td->record = 0;
            if(plumber_ftmap_search(pd, ftname, &td->ft) == PLUMBER_NOTOK) {
                fprintf(stderr, "tblrec: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            free(ftname);
            break;

        case PLUMBER_COMPUTE:
            td = pd->last->ud;
            trig = sporth_stack_pop_float(stack);
            td->val = sporth_stack_pop_float(stack);

            if(trig != 0) {
                if(td->record == 1) {
                    td->record = 0;
                } else {
                    td->record = 1;
                    td->index = 0;
                    memset(td->ft->tbl, 0, sizeof(SPFLOAT) * td->ft->size);
                }
            }

            if(td->record) {
                td->ft->tbl[td->index] = td->val;
                td->index = (td->index + 1) % td->ft->size;
            }
            break;

        case PLUMBER_DESTROY:
            td = pd->last->ud;
            free(td);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!\n");
            break;
    }
    return PLUMBER_OK;
}

