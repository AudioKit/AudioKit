/*
 * RMS
 * 
 * This code has been extracted from the Csound opcode "rms".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Barry Vercoe, John ffitch, Gabriel Maldonado
 * Year: 1991
 * Location: Opcodes/ugens5.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846	
#endif 

int sp_rms_create(sp_rms **p)
{
    *p = malloc(sizeof(sp_rms));
    return SP_OK;
}

int sp_rms_destroy(sp_rms **p)
{
    free(*p);
    return SP_OK;
}

int sp_rms_init(sp_data *sp, sp_rms *p)
{
    p->ihp = 10;
    p->istor = 0;

    SPFLOAT b;

    b = 2.0 - cos((SPFLOAT)(p->ihp * (2 * M_PI / sp->sr)));
    p->c2 = b - sqrt(b*b - 1.0);
    p->c1 = 1.0 - p->c2;
    if (!p->istor) p->prvq = 0.0;
    return SP_OK;
}

int sp_rms_compute(sp_data *sp, sp_rms *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT q;
    SPFLOAT c1 = p->c1, c2 = p->c2;

    q = p->prvq;
    
    SPFLOAT as = *in;
    q = c1 * as * as + c2 * q;
    
    p->prvq = q;
    *out = sqrt(q);
    return SP_OK;
}
