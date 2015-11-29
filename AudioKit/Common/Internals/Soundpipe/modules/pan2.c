/*
 * Pan2
 * 
 * This code has been extracted from the Csound opcode "pan2"
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): John ffitch
 * Year: 2007
 * Location: Opcodes/pan2.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846	
#endif 

#define SQRT2 1.41421356237309504880


int sp_pan2_create(sp_pan2 **p)
{
    *p = malloc(sizeof(sp_pan2));
    return SP_OK;
}

int sp_pan2_destroy(sp_pan2 **p)
{
    free(*p);
    return SP_OK;
}

int sp_pan2_init(sp_data *sp, sp_pan2 *p)
{
    p->type = 0;
    p->pan = 0;
    return SP_OK;
}

int sp_pan2_compute(sp_data *sp, sp_pan2 *p, SPFLOAT *in, SPFLOAT *out1, SPFLOAT *out2)
{
    /* Send the signal's input to the output */
    uint32_t type = p->type;
    SPFLOAT pan = (1 + p->pan) * 0.5;
    SPFLOAT cc, ss, l, r;

    type %= 4;

    switch (type) {
        /* Equal power */
        case 0:
        pan = M_PI * 0.5 * pan;
        *out1 = *in * cos(pan);
        *out2 = *in * sin(pan);
        break;

        /* Square root */
        case 1:
        *out1 = *in * sqrt(pan);
        *out2 = *in * sqrt(1.0 - pan);
        break;

        /* simple linear */
        case 2:
        *out1 = *in * (1.0 - pan);
        *out2 = *in * pan;
        break;

        /* Equal power (alternative) */
        case 3:

        cc = cos(M_PI * pan * 0.5);
        ss = sin(M_PI * pan * 0.5);
        l = SQRT2 * (cc + ss) * 0.5;
        r = SQRT2 * (cc - ss) * 0.5;
        *out1 = *in * l;
        *out2 = *in * r;
        break;
    }

    return SP_OK;
}
