#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

typedef struct {
    sp_ftbl *ft;
    SPFLOAT val;
    unsigned int index;
} sporth_tbl_d;

int sporth_tget(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sporth_tbl_d *td;
    char *ftname;

    switch(pd->mode){
        case PLUMBER_CREATE:
            td = malloc(sizeof(sporth_tbl_d));
            plumber_add_ugen(pd, SPORTH_TGET, td);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for tget\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            if(plumber_ftmap_search(pd, ftname, &td->ft) == PLUMBER_NOTOK) {
                fprintf(stderr, "tget: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            free(ftname);
            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_INIT:
            td = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            free(ftname);
            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_COMPUTE:
            td = pd->last->ud;
            td->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % td->ft->size;
            sporth_stack_push_float(stack, td->ft->tbl[td->index]);
            break;

        case PLUMBER_DESTROY:
            td = pd->last->ud;
            free(td);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_tset(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sporth_tbl_d *td;
    char *ftname;

    switch(pd->mode){
        case PLUMBER_CREATE:
            td = malloc(sizeof(sporth_tbl_d));
            plumber_add_ugen(pd, SPORTH_TSET, td);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for tset\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            td->val = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search(pd, ftname, &td->ft) == PLUMBER_NOTOK) {
                fprintf(stderr, "tset: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            free(ftname);
            break;

        case PLUMBER_INIT:
            td = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            td->val = sporth_stack_pop_float(stack);
            td->ft->tbl[td->index] = td->val;
            free(ftname);
            break;

        case PLUMBER_COMPUTE:
            td = pd->last->ud;
            td->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % td->ft->size;
            td->val = sporth_stack_pop_float(stack);
            td->ft->tbl[td->index] = td->val;
            break;

        case PLUMBER_DESTROY:
            td = pd->last->ud;
            free(td);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_tblsize(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    sp_ftbl *ft;
    size_t *tsize;

    switch(pd->mode){
        case PLUMBER_CREATE:
            tsize = malloc(sizeof(uint32_t));
            plumber_add_ugen(pd, SPORTH_TBLSIZE, tsize);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for tblsize\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                fprintf(stderr, "tblsize: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            *tsize = ft->size;
            free(ftname);
            sporth_stack_push_float(stack, *tsize);
            break;

        case PLUMBER_INIT:
            tsize = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            *tsize = ft->size;
            free(ftname);
            sporth_stack_push_float(stack, *tsize);
            break;

        case PLUMBER_COMPUTE:
            tsize = pd->last->ud;
            sporth_stack_push_float(stack, (SPFLOAT) *tsize);
            break;

        case PLUMBER_DESTROY:
            tsize = pd->last->ud;
            free(tsize);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_tbldur(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    sp_ftbl *ft;
    SPFLOAT *tlen;

    switch(pd->mode){
        case PLUMBER_CREATE:
            tlen = malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_TBLDUR, tlen);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for tget\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                fprintf(stderr, "tblen: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            *tlen = (SPFLOAT) ft->size / pd->sp->sr;
            free(ftname);
            sporth_stack_push_float(stack, (SPFLOAT) *tlen);
            break;

        case PLUMBER_INIT:
            tlen = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            free(ftname);
            sporth_stack_push_float(stack, (SPFLOAT) *tlen);
            break;

        case PLUMBER_COMPUTE:
            tlen = pd->last->ud;
            sporth_stack_push_float(stack, (SPFLOAT) *tlen);
            break;

        case PLUMBER_DESTROY:
            tlen = pd->last->ud;
            free(tlen);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}
