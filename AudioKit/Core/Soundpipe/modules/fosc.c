/*
 * Fosc
 *
 * This code has been extracted from the Csound opcode "foscili".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Barry Vercoe, John ffitch
 * Year: 1991
 * Location: OOps/ugens3.c
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_fosc_create(sp_fosc **p)
{
    *p = malloc(sizeof(sp_fosc));
    return SP_OK;
}

int sp_fosc_destroy(sp_fosc **p)
{
    free(*p);
    return SP_OK;
}

int sp_fosc_init(sp_data *sp, sp_fosc *p, sp_ftbl *ft)
{
    p->freq = 440;
    p->amp = 0.4;
    p->iphs = 0.0;
    p->ft = ft;

    p->mod = 1.0;
    p->car = 1.0;
    p->indx = 1.0;

    p->cphs = p->mphs = (int32_t)(p->iphs * SP_FT_MAXLEN);

    return SP_OK;
}

int sp_fosc_compute(sp_data *sp, sp_fosc *p, SPFLOAT *in, SPFLOAT *out)
{

    sp_ftbl *ftp;

    SPFLOAT  amp, cps, fract, v1, v2, car, fmod, cfreq, mod;
    SPFLOAT  xcar, xmod, ndx, *ftab;
    int32_t  mphs, cphs, minc, cinc, lobits;
    SPFLOAT  sicvt = p->ft->sicvt;
    SPFLOAT  *ft;

    ftp = p->ft;
    ft = ftp->tbl;
    lobits = ftp->lobits;
    mphs = p->mphs;
    cphs = p->cphs;
    cps  = p->freq;
    amp  = p->amp;
    xcar = p->car;
    xmod = p->mod;

    car = cps * xcar;
    mod = cps * xmod;
    ndx = p->indx * mod;
    minc = (int32_t)(mod * sicvt);
    mphs &= SP_FT_PHMASK;
    fract = ((mphs) & ftp->lomask) * ftp->lodiv;
    ftab = ft + (mphs >> lobits);
    v1 = ftab[0];

    if(ftab[0] == p->ft->tbl[p->ft->size - 1]) {
        v2 = p->ft->tbl[0];
    } else {
        v2 = ftab[1];
    }

    fmod = (v1 + (v2 - v1) * fract) * ndx;
    mphs += minc;
    cfreq = car + fmod;
    cinc = (int32_t)(cfreq * sicvt);
    cphs &= SP_FT_PHMASK;
    fract = ((cphs) & ftp->lomask) * ftp->lodiv;
    ftab = ft + (cphs >>lobits);
    v1 = ftab[0];

    if(ftab[0] == p->ft->tbl[p->ft->size - 1]) {
        v2 = p->ft->tbl[0];
    } else {
        v2 = ftab[1];
    }

    *out = (v1 + (v2 - v1) * fract) * amp;
    cphs += cinc;
    p->mphs = mphs;
    p->cphs = cphs;

    return SP_OK;
}
