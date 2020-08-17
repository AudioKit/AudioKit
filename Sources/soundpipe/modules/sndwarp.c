/*
 * Sndwarp
 *
 * This code has been extracted from the Csound opcode "sndwarp".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Richard Karpen, John ffitch
 * Year: 1997
 * Location: Opcodes/sndwarp.c
 */

#include <stdlib.h>
#include "soundpipe.h"

#define unirand(x) ((SPFLOAT) sp_rand(x) / SP_RANDMAX)

struct sp_sndwarp_warpsection {
    int32_t cnt, wsize, flag;
    SPFLOAT ampincr, ampphs, offset;
};


int sp_sndwarp_create(sp_sndwarp **p)
{
    *p = malloc(sizeof(sp_sndwarp));
    return SP_OK;
}

int sp_sndwarp_destroy(sp_sndwarp **p)
{
    sp_sndwarp *pp = *p;
    sp_auxdata_free(&pp->auxch);
    free(*p);
    return SP_OK;
}

int sp_sndwarp_init(sp_data *sp, sp_sndwarp *p,
                    sp_ftbl *ft_samp, sp_ftbl *ft_win,
                    int32_t maxoverlap)
{
    int32_t i;
    int32_t nsections;
    sp_sndwarp_warpsection *exp;
    char *auxp;

    p->begin = 0;
    p->wsize = 0.1;
    p->randw = 0.02;
    p->overlap = 5;
    p->timemode = 1;

    nsections = maxoverlap;
    p->overlap = maxoverlap;
    sp_auxdata_alloc(&p->auxch, (size_t)nsections*sizeof(sp_sndwarp_warpsection));
    auxp = p->auxch.ptr;
    p->nsections = nsections;
    p->exp = (sp_sndwarp_warpsection *)auxp;

    p->ft_samp  = ft_samp;
    p->sampflen = (int) ft_samp->size;

    p->ft_win = ft_win;
    p->flen = (int) ft_win->size;

    p->maxFr = -1 + (int) ft_samp->size;
    p->prFlg = 1;    /* true */

    exp = p->exp;
    for (i=0; i< p->nsections; i++) {
      if (i==0) {
        exp[i].wsize = (int32_t)(p->wsize * sp->sr);
        exp[i].cnt = 0;
        exp[i].ampphs = 0.0;
      } else {
        exp[i].wsize = (int32_t) ((p->wsize + (unirand(sp) * (p->randw))) * sp->sr);
        exp[i].cnt=(int32_t)(exp[i].wsize*((SPFLOAT)i/(p->overlap)));
        exp[i].ampphs = p->flen*((SPFLOAT)i/(p->overlap));
      }
      exp[i].offset = (SPFLOAT)p->begin * sp->sr;
      exp[i].ampincr = (SPFLOAT)p->flen/(exp[i].wsize-1);
    }
    p->ampcode = 1;
    p->timewarpcode = 1;
    p->resamplecode = 1;
    p->amp = 1;
    p->timewarp = 2;
    p->resample = 2;
    return SP_OK;
}

int sp_sndwarp_compute(sp_data *sp, sp_sndwarp *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT frm_0,frm_1;
    int32_t base, longphase;
    SPFLOAT frac, frIndx;
    SPFLOAT r1, amp, timewarpby, resample;
    sp_sndwarp_warpsection *exp;
    sp_ftbl *ft_win, *ft_samp;
    int32_t i;
    SPFLOAT v1, v2, windowamp, fract;
    SPFLOAT flen = (SPFLOAT)p->flen;
    SPFLOAT wsize = p->wsize;
    int32_t overlap = p->overlap;

    r1 = 0;
    exp = p->exp;
    ft_win = p->ft_win;
    ft_samp = p->ft_samp;

    if(overlap > p->nsections) overlap = p->nsections;
    if(overlap <= 0) overlap = 1;

    for (i=0; i<overlap; i++) {
        resample = p->resample;
        timewarpby = p->timewarp;
        amp = p->amp;
        if (exp[i].cnt < exp[i].wsize) goto skipover;

        if (p->timemode)
            exp[i].offset=(sp->sr * timewarpby)+(p->begin * sp->sr);
        else
            exp[i].offset += (SPFLOAT)exp[i].wsize/(timewarpby);

        exp[i].cnt=0;
        exp[i].wsize = (int32_t) ((wsize + (unirand(sp) * (p->randw))) * sp->sr);
        exp[i].ampphs = 0.0;
        exp[i].ampincr = flen/(exp[i].wsize-1);

        skipover:

        frIndx =(SPFLOAT)((exp[i].cnt * resample)  + exp[i].offset);
        exp[i].cnt += 1;
        if (frIndx > (SPFLOAT)p->maxFr) { /* not past last one */
            frIndx = (SPFLOAT)p->maxFr;
            if (p->prFlg) {
                p->prFlg = 0;   /* false */
                /* fprintf(stderr, "SNDWARP at last sample frame"); */
            }
        }
        longphase = (int32_t)exp[i].ampphs;
        if (longphase > p->flen-1) longphase = p->flen-1;
        v1 = *(ft_win->tbl + longphase);
        v2 = *(ft_win->tbl + longphase + 1);
        fract = (SPFLOAT)(exp[i].ampphs - (int32_t)exp[i].ampphs);
        windowamp = v1 + (v2 - v1)*fract;
        exp[i].ampphs += exp[i].ampincr;

        base = (int32_t)frIndx;    /* index of basis frame of interpolation */
        frac = ((SPFLOAT)(frIndx - (SPFLOAT)base));
        frm_0 = *(ft_samp->tbl + base);
        frm_1 = *(ft_samp->tbl + (base+1));
        if (frac != 0.0) {
            r1 += ((frm_0 + frac*(frm_1-frm_0)) * windowamp) * amp;
        }
        else {
            r1 += (frm_0 * windowamp) * amp;
        }
        if (p->ampcode) amp++;
        if (p->timewarpcode) timewarpby++;
        if (p->resamplecode) resample++;
    }

    *out = r1;
    return SP_OK;
}
