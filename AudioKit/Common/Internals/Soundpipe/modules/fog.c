/*
 * Foo
 * 
 * This is a dummy module. It doesn't do much.
 * Feel free to use this as a boilerplate template.
 * 
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"


#define PFRAC1(x)   ((SPFLOAT)((x) & ftp1->lomask) * ftp1->lodiv)

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

#define MPIDSR -M_PI/sp->sr

static SPFLOAT intpow1(SPFLOAT x, int32_t n)
{
    SPFLOAT ans = 1.0;
    while (n!=0) {
      if (n&1) ans = ans * x;
      n >>= 1;
      x = x*x;
    }
    return ans;
}

static SPFLOAT intpow(SPFLOAT x, int32_t n)
{
    if (n<0) {
      n = -n;
      x = 1.0/x;
    }
    return intpow1(x, n);
}

static int newpulse(sp_data *sp, sp_fog *p, sp_fog_overlap *ovp, SPFLOAT amp,
                    SPFLOAT fund, SPFLOAT ptch)
{
    SPFLOAT octamp = amp, oct;
    SPFLOAT form = ptch / p->ftp1->sicvt, fogcvt = p->fogcvt;
    int32_t rismps, newexp = 0;
    ovp->timrem = (int32_t)(p->dur * sp->sr);

    if ((oct = p->oct) > 0.0) {
        int32_t ioct = (int32_t)oct, bitpat = (int) ~(-1L << ioct);
        if (bitpat & ++p->fofcount) return(0);
        if ((bitpat += 1) & p->fofcount) octamp *= (1.0) + ioct - oct;
    }

    if (fund == 0.0) ovp->formphs = 0;
    else ovp->formphs = (int32_t)(p->fundphs * form / fund) & SP_FT_PHMASK;

    ovp->forminc = (int32_t)(ptch * fogcvt);

    if (p->band != p->prvband) {
        p->prvband = p->band;
        p->expamp = exp(p->band * MPIDSR);
        newexp = 1;
    }

    if (p->ris >= (1.0 / sp->sr)  && form != 0.0) {
        ovp->risphs = (uint32_t)(ovp->formphs / (fabs(form))
                                    / p->ris);
        ovp->risinc = (int32_t)(p->ftp1->sicvt / p->ris);
        rismps = SP_FT_MAXLEN / ovp->risinc;
    } else {
        ovp->risphs = SP_FT_MAXLEN;
        rismps = 0;
    }
    ovp->formphs = (ovp->formphs + p->spdphs) & SP_FT_PHMASK;

    if (newexp || rismps != p->prvsmps) {
        if ((p->prvsmps = rismps)) p->preamp = intpow(p->expamp, -rismps);
        else p->preamp = 1.0;
    }

    ovp->curamp = octamp * p->preamp;
    ovp->expamp = p->expamp;

    if ((ovp->dectim = (int32_t)(p->dec * sp->sr )) > 0) {
        ovp->decinc = (int32_t)(p->ftp1->sicvt / p->dec);
    }

    ovp->decphs = SP_FT_PHMASK;

    ovp->pos = p->spd * p->ftp1->size;
    ovp->inc = p->trans;

    return 1;
}

int sp_fog_create(sp_fog **p)
{
    *p = malloc(sizeof(sp_fog));
    return SP_OK;
}

int sp_fog_destroy(sp_fog **p)
{
    sp_fog *pp = *p;
    sp_auxdata_free(&pp->auxch);
    free(*p);
    return SP_OK;
}

int sp_fog_init(sp_data *sp, sp_fog *p, sp_ftbl *wav, sp_ftbl *win, int iolaps, SPFLOAT iphs)
{
    p->amp = 0.5;
    p->dens = 80;
    p->trans = 1;
    p->spd = 0;
    p->oct = 0;
    p->band = 50;
    p->ris = 0.01;
    p->dec = 0.07;
    p->dur = 0.1;
    p->iolaps = iolaps;
    p->iphs = iphs;
    p->ftp1 = wav;
    p->ftp2 = win;

    sp_fog_overlap *ovp, *nxtovp;
    int32_t olaps;
    p->fogcvt = SP_FT_MAXLEN/(p->ftp1)->size;
    p->spdphs = 0L;
    if (p->iphs == 0.0) p->fundphs = SP_FT_MAXLEN;
    else p->fundphs = (int32_t)(p->iphs * SP_FT_MAXLEN) & SP_FT_PHMASK;

    olaps = (int32_t)p->iolaps;

    sp_auxdata_alloc(&p->auxch, (size_t)olaps * sizeof(sp_fog_overlap));
    ovp = &p->basovrlap;
    nxtovp = (sp_fog_overlap *) p->auxch.ptr;

    do {
        ovp->nxtact = NULL;
        ovp->nxtfree = nxtovp;
        ovp = nxtovp++;
    } while (--olaps);

    ovp->nxtact  = NULL;
    ovp->nxtfree = NULL;
    p->fofcount = -1;
    p->prvband = 0.0;
    p->expamp = 1.0;
    p->prvsmps = 0;
    p->preamp = 1.0;
    p->fmtmod  = 0;
    return SP_OK;
}

int sp_fog_compute(sp_data *sp, sp_fog *p, SPFLOAT *in, SPFLOAT *out)
{
    sp_fog_overlap *ovp;
    sp_ftbl *ftp1,  *ftp2;
    SPFLOAT  amp, fund, ptch, speed;
    SPFLOAT fract;
    int32_t fund_inc;

    int32_t ndx;
    SPFLOAT x1, x2;


    amp = p->amp;
    fund = p->dens;
    ptch = p->trans;
    speed = p->spd;
    ftp1 = p->ftp1;
    ftp2 = p->ftp2;
    fund_inc = (int32_t)(fund * ftp1->sicvt);

    if (p->fundphs & SP_FT_MAXLEN) {
        p->fundphs &= SP_FT_PHMASK;
        ovp = p->basovrlap.nxtfree;
        if (newpulse(sp, p, ovp, amp, fund, ptch)) {
            ovp->nxtact = p->basovrlap.nxtact;
            p->basovrlap.nxtact = ovp;
            p->basovrlap.nxtfree = ovp->nxtfree;
        }
    }
    *out = 0.0;
    ovp = &p->basovrlap;
    while (ovp->nxtact != NULL) {
        SPFLOAT result;
        sp_fog_overlap *prvact = ovp;
        ovp = ovp->nxtact;
        ndx = floor(ovp->pos);
        fract = ovp->pos - ndx;

        while(ndx >= ftp1->size) {
            ndx -= ftp1->size;
        }

        while(ndx < 0) ndx += ftp1->size;

        x1 = ftp1->tbl[ndx];
        x2 = ftp1->tbl[ndx + 1];

        result = x1 + (x2 - x1) * fract;

        ovp->pos += ovp->inc;

        if (ovp->risphs < SP_FT_MAXLEN) {
        result *= *(ftp2->tbl + (ovp->risphs >> ftp2->lobits) );
        ovp->risphs += ovp->risinc;
        }
        if (ovp->timrem <= ovp->dectim) {
            result *= *(ftp2->tbl + (ovp->decphs >> ftp2->lobits) );
            if ((ovp->decphs -= ovp->decinc) < 0)
            ovp->decphs = 0;
        }
        *out += (result * ovp->curamp);
        if (--ovp->timrem) ovp->curamp *= ovp->expamp;
        else {
            prvact->nxtact = ovp->nxtact;
            ovp->nxtfree = p->basovrlap.nxtfree;
            p->basovrlap.nxtfree = ovp;
            ovp = prvact;
        }
    }

    p->fundphs += fund_inc;
    p->spdphs = (int32_t)(speed * SP_FT_MAXLEN);
    p->spdphs &= SP_FT_PHMASK;
    return SP_OK;
}
