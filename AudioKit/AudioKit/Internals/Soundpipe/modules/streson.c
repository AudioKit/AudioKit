/*
 * Streson
 * 
 * This code has been extracted from the Csound opcode "streson".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): John ffitch, Victor Lazzarini
 * Year: 1996, 1998
 * Location: Opcodes/repluck.c
 *
 */


#include <stdlib.h>
#include "soundpipe.h"

int sp_streson_create(sp_streson **p) 
{
    *p = malloc(sizeof(sp_streson));
    return SP_OK;
}

int sp_streson_destroy(sp_streson **p) 
{
    sp_streson *pp = *p;
    sp_auxdata_free(&pp->buf);
    free(*p);
    return SP_OK;
}

int sp_streson_init(sp_data *sp, sp_streson *p) 
{
    int n;
    p->freq = 440.0;
    p->fdbgain = 0.8;
    p->size = (int) (sp->sr/20);   /* size of delay line */
    sp_auxdata_alloc(&p->buf, p->size * sizeof(SPFLOAT));
    p->Cdelay = (SPFLOAT*) p->buf.ptr; /* delay line */
    p->LPdelay = p->APdelay = 0.0; /* reset the All-pass and Low-pass delays */
    p->wpointer = p->rpointer = 0; /* reset the read/write pointers */
    for (n = 0; n < p->size; n++){
      p->Cdelay[n] = 0.0;
    }
    return SP_OK;
}

int sp_streson_compute(sp_data *sp, sp_streson *p, SPFLOAT *in, SPFLOAT *out) 
{
    SPFLOAT g = p->fdbgain;
    SPFLOAT freq;
    SPFLOAT a, s, w, sample, tdelay, fracdelay;
    int delay;
    int rp = p->rpointer, wp = p->wpointer;
    int size = p->size;
    SPFLOAT APdelay = p->APdelay;
    SPFLOAT LPdelay = p->LPdelay;
    int vdt;

    freq = p->freq;
    if (freq < 20.0) freq = 20.0;   /* lowest freq is 20 Hz */
    tdelay = sp->sr/freq;
    delay = (int) (tdelay - 0.5); /* comb delay */
    fracdelay = tdelay - (delay + 0.5); /* fractional delay */
    vdt = size - delay;       /* set the var delay */
    a = (1.0-fracdelay)/(1.0+fracdelay);   /* set the all-pass gain */
    
    SPFLOAT tmpo;
    rp = (vdt + wp);
    if (rp >= size) rp -= size;
    tmpo = p->Cdelay[rp];
    w = *in + tmpo;
    s = (LPdelay + w)*0.5;
    LPdelay = w;
    *out = sample = APdelay + s*a;
    APdelay = s - (sample*a);
    p->Cdelay[wp] = sample*g;
    wp++;
    if (wp == size) wp=0;
    p->rpointer = rp; p->wpointer = wp;
    p->LPdelay = LPdelay; p->APdelay = APdelay;
    return SP_OK;
}
