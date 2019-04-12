/*
 * Tabread
 *
 * This code has been extracted from the Csound opcode "tablei".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author: Victor Lazzarini
 * Year: 2013
 * Location: OOps/ugtabs.c
 *
 */
#include <stdlib.h>
#include "math.h"
#include "soundpipe.h"

int sp_tabread_create(sp_tabread **p)
{
    *p = malloc(sizeof(sp_tabread));
    return SP_OK;
}

int sp_tabread_destroy(sp_tabread **p)
{
    free(*p);
    return SP_OK;
}

int sp_tabread_init(sp_data *sp, sp_tabread *p, sp_ftbl *ft, int mode)
{
    p->ft = ft;
    p->mode = (SPFLOAT) mode;
    p->offset = 0;
    p->wrap = 0;
    return SP_OK;
}

int sp_tabread_compute(sp_data *sp, sp_tabread *p, SPFLOAT *in, SPFLOAT *out)
{
    int ndx, len = (int)p->ft->size;
    int32_t mask = (int)p->ft->size - 1;
    SPFLOAT index = p->index;
    SPFLOAT *tbl = p->ft->tbl;
    SPFLOAT offset = p->offset;
    SPFLOAT mul = 1, tmp, frac;

    if (p->mode) {
        mul = p->ft->size;
    }else {
        p->mul = 1;
    }

    int32_t iwrap = (int32_t)p->wrap;

    SPFLOAT x1, x2;
    tmp = (index + offset) * mul;
    ndx = floor(tmp);
    frac = tmp - ndx;
    if (iwrap) {
        if ((mask ? 0 : 1)) {
            while(ndx >= len) ndx -= len;
            while(ndx < 0)  ndx += len;
        }
        else ndx &= mask;
    } else {
        if (ndx >= len) ndx = len - 1;
        else if (ndx < 0) ndx = 0;
    }

    x1 = tbl[ndx];
    x2 = tbl[ndx+1];
    *out = x1 + (x2 - x1) * frac;
    return SP_OK;
}
