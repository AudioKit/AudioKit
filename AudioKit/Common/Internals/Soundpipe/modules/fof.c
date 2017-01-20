/*
 * fof
 * 
 * This code has been extracted from the Csound opcode "fof".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): J Michael Clarke
 * Year: 1995
 * Location: Opcodes/ugens7.c
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


static int newpulse(sp_data *sp,
                    sp_fof *p, sp_fof_overlap *ovp, SPFLOAT amp, SPFLOAT fund, SPFLOAT form)
{
    SPFLOAT   octamp = amp, oct;
    int32_t   rismps, newexp = 0;

    ovp->timrem = p->dur * sp->sr;

    if ((oct = p->oct) > 0.0) {
        int32_t ioct = (int32_t)oct, bitpat = (int) ~(-1L << ioct);
        if (bitpat & ++p->fofcount) return(0);
        if ((bitpat += 1) & p->fofcount) octamp *= (1.0 + ioct - oct);
    }
    if (fund == 0.0) ovp->formphs = 0;
    else ovp->formphs = (int32_t)(p->fundphs * form / fund) & SP_FT_PHMASK;

    ovp->forminc = (int32_t)(form * p->ftp1->sicvt);

    if (p->band != p->prvband) {
        p->prvband = p->band;
        p->expamp = exp(p->band * MPIDSR);
        newexp = 1;
    }
    /* Init grain rise ftable phase. Negative kform values make
    the kris (ifnb) initial index go negative and crash csound.
    So insert another if-test with compensating code. */
    if (p->ris >= (1.0 / sp->sr) && form != 0.0) {
        if (form < 0.0 && ovp->formphs != 0)
            ovp->risphs = (int32_t)((SP_FT_MAXLEN - ovp->formphs) / -form / p->ris);
        else ovp->risphs = (int32_t)(ovp->formphs / form / p->ris);

        ovp->risinc = (int32_t)(p->ftp1->sicvt / p->ris);
        rismps = SP_FT_MAXLEN / ovp->risinc;
    } else {
        ovp->risphs = SP_FT_MAXLEN;
        rismps = 0;
    }

    if (newexp || rismps != p->prvsmps) {
        if ((p->prvsmps = rismps))
        p->preamp = intpow(p->expamp, -rismps);
        else p->preamp = 1.0;
    }

    ovp->curamp = octamp * p->preamp;
    ovp->expamp = p->expamp;
    if ((ovp->dectim = (int32_t)(p->dec * sp->sr)) > 0)
        ovp->decinc = (int32_t)(p->ftp1->sicvt / p->dec);
    ovp->decphs = SP_FT_PHMASK;
    return 1;
}

int sp_fof_create(sp_fof **p)
{
    *p = malloc(sizeof(sp_fof));
    return SP_OK;
}

int sp_fof_destroy(sp_fof **p)
{
    sp_fof *pp = *p;
    sp_auxdata_free(&pp->auxch);
    free(*p);
    return SP_OK;
}

int sp_fof_init(sp_data *sp, sp_fof *p, sp_ftbl *sine, sp_ftbl *win, int iolaps, SPFLOAT iphs)
{
    p->amp = 0.5;
    p->fund = 100;
    p->form = 500;
    p->oct = 0;
    p->band = 50;
    p->ris = 0.003;
    p->dec = 0.0007;
    p->dur = 0.02;
    p->iolaps = iolaps;
    p->iphs = iphs;
    p->ftp1 = sine;
    p->ftp2 = win;

    sp_fof_overlap *ovp, *nxtovp;
    int32_t olaps;

    if (p->iphs == 0.0) p->fundphs = SP_FT_MAXLEN;                  
    else p->fundphs = (int32_t)(p->iphs * SP_FT_MAXLEN) & SP_FT_PHMASK;

    olaps = (int32_t)p->iolaps;

    if (p->iphs >= 0.0) {
        sp_auxdata_alloc(&p->auxch, (size_t)olaps * sizeof(sp_fof_overlap));
    }

    ovp = &p->basovrlap;
    nxtovp = (sp_fof_overlap *) p->auxch.ptr;

    do {
        ovp->nxtact = NULL;
        ovp->nxtfree = nxtovp;
        ovp = nxtovp++;
    } while (--olaps);
    ovp->nxtact = NULL;
    ovp->nxtfree = NULL;
    p->fofcount = -1;
    p->prvband = 0.0;
    p->expamp = 1.0;
    p->prvsmps = (int32_t)0;
    p->preamp = 1.0;

    p->ampcod   = 1;
    p->fundcod  = 1;
    p->formcod  = 1;
    p->xincod   = p->ampcod || p->fundcod || p->formcod;
    p->fmtmod = 0;
    p->foftype = 1;
    return SP_OK;
}

int sp_fof_compute(sp_data *sp, sp_fof *p, SPFLOAT *in, SPFLOAT *out)
{
    sp_fof_overlap *ovp;
    sp_ftbl *ftp1, *ftp2;
    SPFLOAT amp, fund, form;
    int32_t fund_inc, form_inc;
    SPFLOAT v1, fract ,*ftab;

    amp = p->amp;
    fund = p->fund;
    form = p->form;
    ftp1 = p->ftp1;
    ftp2 = p->ftp2;
    fund_inc = (int32_t)(fund * ftp1->sicvt);
    form_inc = (int32_t)(form * ftp1->sicvt);

    if (p->fundphs & SP_FT_MAXLEN) {
        p->fundphs &= SP_FT_PHMASK;
        ovp = p->basovrlap.nxtfree;
        if (newpulse(sp, p, ovp, amp, fund, form)) {
            ovp->nxtact = p->basovrlap.nxtact;
            p->basovrlap.nxtact = ovp;
            p->basovrlap.nxtfree = ovp->nxtfree;
        }
    }
    *out = 0.0;
    ovp = &p->basovrlap;
    while (ovp->nxtact != NULL) {
        SPFLOAT  result;
        sp_fof_overlap *prvact = ovp;
        ovp = ovp->nxtact;
        fract = PFRAC1(ovp->formphs);
        ftab = ftp1->tbl + (ovp->formphs >> ftp1->lobits);
        v1 = *ftab++;
        result = v1 + (*ftab - v1) * fract;
        if (p->foftype) {
            if (p->fmtmod)
            ovp->formphs += form_inc;           
            else ovp->formphs += ovp->forminc;
        }
        else {
            /* SPFLOAT ovp->glissbas = kgliss / grain length. ovp->sampct is
             incremented each sample. We add glissbas * sampct to the
             pitch of grain at each a-rate pass (ovp->formphs is the
             index into ifna; ovp->forminc is the stepping factor that
             decides pitch) */
            ovp->formphs += (int32_t)(ovp->forminc + ovp->glissbas * ovp->sampct++);
        }
        ovp->formphs &= SP_FT_PHMASK;
        if (ovp->risphs < SP_FT_MAXLEN) {
            result *= *(ftp2->tbl + (ovp->risphs >> ftp2->lobits) );
            ovp->risphs += ovp->risinc;
        }
        if (ovp->timrem <= ovp->dectim) {
            result *= *(ftp2->tbl + (ovp->decphs >> ftp2->lobits) );
            if ((ovp->decphs -= ovp->decinc) < 0) ovp->decphs = 0;
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
    return SP_OK;
}
