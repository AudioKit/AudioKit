/*
 * Trem
 *
 * This code has been extracted from the Csound opcode "oscili".
 * It has been modified to work as a Soundpipe module and be applied as a tremolo effect.
 *
 * Original Author(s): Barry Vercoe, John FFitch, Robin Whittle
 * Year: 1991
 * Location: OOps/ugens2.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_trem_create(sp_trem **trem)
{
    *trem = malloc(sizeof(sp_trem));
    return SP_OK;
}

int sp_trem_destroy(sp_trem **trem)
{
    free(*trem);
    return SP_NOT_OK;
}

int sp_trem_init(sp_data *sp, sp_trem *trem, sp_ftbl *ft)
{
    trem->freq = 10.0;
    trem->depth = 1.0;
    trem->tbl = ft;
    trem->iphs = 0;
    trem->inc = 0;
    return SP_OK;
}

int sp_trem_compute(sp_data *sp, sp_trem *trem, SPFLOAT *in, SPFLOAT *out)
{
    sp_ftbl *ftp;
    SPFLOAT cps, fract, v1, v2, *ftab, *ft;
    int32_t phs, lobits;
    SPFLOAT sicvt = trem->tbl->sicvt;

    ftp = trem->tbl;
    lobits = trem->tbl->lobits;
    cps = trem->freq;
    phs = trem->lphs;
    ft = trem->tbl->tbl;

    trem->inc = (int32_t)lrintf(cps * sicvt);

    fract = ((phs) & ftp->lomask) * ftp->lodiv;
    ftab = ft + (phs >> lobits);
    v1 = ftab[0];
    v2 = ftab[1];
    *out = *in * (1+(-1.0*trem->depth*(v1 + (v2 - v1) * fract)));
    phs += trem->inc;
    phs &= SP_FT_PHMASK;

    trem->lphs = phs;
    return SP_OK;
}
