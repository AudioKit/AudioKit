/*
 * Jitter
 * 
 * This code has been extracted from the Csound opcode "jitter".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Gabriel Maldonado
 * Year: 1998
 * Location: Opcodes/uggab.c
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

/* the randgabs are essentially magic incantations from Csound */

static SPFLOAT sp_jitter_randgab(sp_data *sp) 
{
    SPFLOAT out = (SPFLOAT) ((sp_rand(sp) >> 1) & 0x7fffffff) *
    (4.656612875245796924105750827168e-10);
    return out;
}

static SPFLOAT sp_jitter_birandgab(sp_data *sp) 
{
    SPFLOAT out = (SPFLOAT) (sp_rand(sp) & 0x7fffffff) *
    (4.656612875245796924105750827168e-10);
    return out;
}

int sp_jitter_create(sp_jitter **p)
{
    *p = malloc(sizeof(sp_jitter));
    return SP_OK;
}

int sp_jitter_destroy(sp_jitter **p)
{
    free(*p);
    return SP_OK;
}

int sp_jitter_init(sp_data *sp, sp_jitter *p)
{
    p->amp = 0.5;
    p->cpsMin = 0.5;
    p->cpsMax = 4; 
    p->num2 = sp_jitter_birandgab(sp);
    p->initflag = 1;
    p->phs=0;
    return SP_OK;
}

int sp_jitter_compute(sp_data *sp, sp_jitter *p, SPFLOAT *in, SPFLOAT *out)
{
    if (p->initflag) {
      p->initflag = 0;
      *out = p->num2 * p->amp;
      p->cps = sp_jitter_randgab(sp) * (p->cpsMax - p->cpsMin) + p->cpsMin;
      p->phs &= SP_FT_PHMASK;
      p->num1 = p->num2;
      p->num2 = sp_jitter_birandgab(sp);
      p->dfdmax = 1.0 * (p->num2 - p->num1) / SP_FT_MAXLEN;
      return SP_OK;
    }
    
    *out = (p->num1 + (SPFLOAT)p->phs * p->dfdmax) * p->amp;
    p->phs += (int32_t)(p->cps * (SPFLOAT)(SP_FT_MAXLEN / sp->sr));

    if (p->phs >= SP_FT_MAXLEN) {
      p->cps   = sp_jitter_randgab(sp) * (p->cpsMax - p->cpsMin) + p->cpsMin;
      p->phs   &= SP_FT_PHMASK;
      p->num1   = p->num2;
      p->num2 =  sp_jitter_birandgab(sp);
      p->dfdmax = 1.0 * (p->num2 - p->num1) / SP_FT_MAXLEN;
    }
    return SP_OK;
}
