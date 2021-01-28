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
    plumber_data *pd = (plumber_data *)ud;

    sporth_tbl_d *td;
    const char *ftname;

    switch(pd->mode){
        case PLUMBER_CREATE:
            td = (sporth_tbl_d*)malloc(sizeof(sporth_tbl_d));
            plumber_add_ugen(pd, SPORTH_TGET, td);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
               plumber_print(pd,"Init: not enough arguments for tget\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            if(plumber_ftmap_search(pd, ftname, &td->ft) == PLUMBER_NOTOK) {
                plumber_print(pd, "tget: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            sporth_stack_push_float(stack, td->ft->tbl[td->index]);
            break;

        case PLUMBER_INIT:
            td = (sporth_tbl_d*)pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            sporth_stack_push_float(stack, td->ft->tbl[td->index]);
            break;

        case PLUMBER_COMPUTE:
            td = (sporth_tbl_d*)pd->last->ud;
            td->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % td->ft->size;
            sporth_stack_push_float(stack, td->ft->tbl[td->index]);
            break;

        case PLUMBER_DESTROY:
            td = (sporth_tbl_d*)pd->last->ud;
            free(td);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_tset(sporth_stack *stack, void *ud)
{
    plumber_data *pd = (plumber_data *)ud;

    sporth_tbl_d *td;
    const char *ftname;

    switch(pd->mode){
        case PLUMBER_CREATE:
            td = (sporth_tbl_d*)malloc(sizeof(sporth_tbl_d));
            plumber_add_ugen(pd, SPORTH_TSET, td);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
               plumber_print(pd,"Init: not enough arguments for tset\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            td->val = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search(pd, ftname, &td->ft) == PLUMBER_NOTOK) {
                plumber_print(pd, "tset: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            td->ft->tbl[td->index] = td->val;
            break;

        case PLUMBER_INIT:
            td = (sporth_tbl_d*)pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            td->index = floor(sporth_stack_pop_float(stack));
            td->val = sporth_stack_pop_float(stack);
            td->ft->tbl[td->index] = td->val;
            break;

        case PLUMBER_COMPUTE:
            td = (sporth_tbl_d*)pd->last->ud;
            td->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % td->ft->size;
            td->val = sporth_stack_pop_float(stack);
            td->ft->tbl[td->index] = td->val;
            break;

        case PLUMBER_DESTROY:
            td = (sporth_tbl_d*)pd->last->ud;
            free(td);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_tblsize(sporth_stack *stack, void *ud)
{
    plumber_data *pd = (plumber_data *)ud;

    const char *ftname;
    sp_ftbl *ft;
    size_t *tsize;

    switch(pd->mode){
        case PLUMBER_CREATE:
            tsize = (size_t*)malloc(sizeof(size_t));
            plumber_add_ugen(pd, SPORTH_TBLSIZE, tsize);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               plumber_print(pd,"Init: not enough arguments for tblsize\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                plumber_print(pd, "tblsize: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            *tsize = ft->size;
            sporth_stack_push_float(stack, *tsize);
            break;

        case PLUMBER_INIT:
            tsize = (size_t*)pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            sporth_stack_push_float(stack, *tsize);
            break;

        case PLUMBER_COMPUTE:
            tsize = (size_t*)pd->last->ud;
            sporth_stack_push_float(stack, (SPFLOAT) *tsize);
            break;

        case PLUMBER_DESTROY:
            tsize = (size_t*)pd->last->ud;
            free(tsize);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_tbldur(sporth_stack *stack, void *ud)
{
    plumber_data *pd = (plumber_data *)ud;

    const char *ftname;
    sp_ftbl *ft;
    SPFLOAT *tlen;

    switch(pd->mode){
        case PLUMBER_CREATE:
            tlen = (float*)malloc(sizeof(SPFLOAT));
            plumber_add_ugen(pd, SPORTH_TBLDUR, tlen);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               plumber_print(pd,"Init: not enough arguments for tget\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                plumber_print(pd, "tblen: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            *tlen = (SPFLOAT) ft->size / pd->sp->sr;
            sporth_stack_push_float(stack, (SPFLOAT) *tlen);
            break;

        case PLUMBER_INIT:
            tlen = (SPFLOAT*)pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            sporth_stack_push_float(stack, (SPFLOAT) *tlen);
            break;

        case PLUMBER_COMPUTE:
            tlen = (SPFLOAT*)pd->last->ud;
            sporth_stack_push_float(stack, (SPFLOAT) *tlen);
            break;

        case PLUMBER_DESTROY:
            tlen = (SPFLOAT*)pd->last->ud;
            free(tlen);
            break;

        default:
            plumber_print(pd,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_talias(sporth_stack *stack, void *ud)
{
    plumber_data *pd = (plumber_data *)ud;

    const char *ftname;
    const char *varname;
    uint32_t index;
    SPFLOAT *var;
    sp_ftbl *ft;

    switch(pd->mode){
        case PLUMBER_CREATE:
            plumber_add_ugen(pd, SPORTH_TALIAS, NULL);
            if(sporth_check_args(stack, "sfs") != SPORTH_OK) {
               plumber_print(pd,"Init: incorrect arguments for talias\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            index = sporth_stack_pop_float(stack);
            varname = sporth_stack_pop_string(stack);

            if(plumber_ftmap_search(pd, ftname, &ft) == PLUMBER_NOTOK) {
                plumber_print(pd, "talias: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }

            var = &ft->tbl[index];

            plumber_ftmap_delete(pd, 0);
            plumber_ftmap_add_userdata(pd, varname, var);
            plumber_ftmap_delete(pd, 1);

            break;

        case PLUMBER_INIT:
            ftname = sporth_stack_pop_string(stack);
            index = sporth_stack_pop_float(stack);
            varname = sporth_stack_pop_string(stack);
            break;

        case PLUMBER_COMPUTE:
            sporth_stack_pop_float(stack);
            break;

        case PLUMBER_DESTROY:
            break;
    }
    return PLUMBER_OK;
}
