#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "plumber.h"

typedef struct {
    plumber_argtbl *at;
    SPFLOAT val;
    unsigned int index;
} sporth_atbl_d;

int sporth_atget(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sporth_atbl_d *atd;
    plumber_argtbl *at;
    char *ftname;

    switch(pd->mode){
        case PLUMBER_CREATE:
            atd = malloc(sizeof(sporth_atbl_d));
            plumber_add_ugen(pd, SPORTH_ATGET, atd);
            if(sporth_check_args(stack, "fs") != SPORTH_OK) {
               fprintf(stderr,"atget: not enough arguments\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            atd->index = floor(sporth_stack_pop_float(stack));
            if(plumber_ftmap_search_userdata(pd, ftname, (void **)&at) == PLUMBER_NOTOK) {
                fprintf(stderr, "atget: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            } printf("found argtable %s of size %d\n", ftname, at->size);
            atd->at = at;
            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_INIT:
            atd = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            atd->index = floor(sporth_stack_pop_float(stack));
            sporth_stack_push_float(stack, 0.0);
            break;

        case PLUMBER_COMPUTE:
            atd = pd->last->ud;
            atd->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % atd->at->size;
            sporth_stack_push_float(stack, *atd->at->tbl[atd->index]);
            break;

        case PLUMBER_DESTROY:
            atd = pd->last->ud;
            free(atd);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_atset(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    sporth_atbl_d *atd;
    plumber_argtbl *at;
    char *ftname;

    switch(pd->mode){
        case PLUMBER_CREATE:
            atd = malloc(sizeof(sporth_atbl_d));
            plumber_add_ugen(pd, SPORTH_ATSET, atd);
            if(sporth_check_args(stack, "ffs") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for tset\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            atd->index = floor(sporth_stack_pop_float(stack));
            atd->val = sporth_stack_pop_float(stack);
            if(plumber_ftmap_search_userdata(pd, ftname, (void **)&at) == PLUMBER_NOTOK) {
                fprintf(stderr, "tset: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            atd->at = at;
            break;

        case PLUMBER_INIT:
            atd = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            atd->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % atd->at->size;
            atd->val = sporth_stack_pop_float(stack);
            /* TODO: figure out why this segfaults  
            *atd->at->tbl[atd->index] = atd->val;
            */
            break;

        case PLUMBER_COMPUTE:
            atd = pd->last->ud;
            atd->index = (unsigned int) floor(sporth_stack_pop_float(stack)) % atd->at->size;
            atd->val = sporth_stack_pop_float(stack);
            *atd->at->tbl[atd->index] = atd->val;
            break;

        case PLUMBER_DESTROY:
            atd = pd->last->ud;
            free(atd);
            break;

        default:
            fprintf(stderr,"Error: Unknown mode!");
            break;
    }
    return PLUMBER_OK;
}

int sporth_atblsize(sporth_stack *stack, void *ud)
{
    plumber_data *pd = ud;

    char *ftname;
    plumber_argtbl *at;
    size_t *tsize;

    switch(pd->mode){
        case PLUMBER_CREATE:
            tsize = malloc(sizeof(uint32_t));
            plumber_add_ugen(pd, SPORTH_ATBLSIZE, tsize);
            if(sporth_check_args(stack, "s") != SPORTH_OK) {
               fprintf(stderr,"Init: not enough arguments for atblsize\n");
                return PLUMBER_NOTOK;
            }
            ftname = sporth_stack_pop_string(stack);
            if(plumber_ftmap_search_userdata(pd, ftname, (void **)&at) == PLUMBER_NOTOK) {
                fprintf(stderr, "atblsize: could not find table '%s'\n", ftname);
                stack->error++;
                return PLUMBER_NOTOK;
            }
            *tsize = at->size;
            sporth_stack_push_float(stack, *tsize);
            break;

        case PLUMBER_INIT:
            tsize = pd->last->ud;
            ftname = sporth_stack_pop_string(stack);
            *tsize = at->size;
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

