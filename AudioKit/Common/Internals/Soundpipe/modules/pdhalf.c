/*
 * PDHalf
 *
 * This code has been extracted from the Csound opcode "pdhalf".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Anthony M. Kozar Jr.
 * Year: 2004
 * Location: Opcodes/shape.c
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_pdhalf_create(sp_pdhalf **p)
{
    *p = malloc(sizeof(sp_pdhalf));
    return SP_OK;
}

int sp_pdhalf_destroy(sp_pdhalf **p)
{
    free(*p);
    return SP_OK;
}

int sp_pdhalf_init(sp_data *sp, sp_pdhalf *p)
{
    p->ibipolar = 0;
    p->ifullscale = 1.0;
    p->amount = 0;
    return SP_OK;
}

int sp_pdhalf_compute(sp_data *sp, sp_pdhalf *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT cur, maxampl, midpoint, leftslope, rightslope;

    maxampl = p->ifullscale;
    if (maxampl == 0.0)  maxampl = 1.0;

    if (p->ibipolar != 0.0) {
        midpoint =  (p->amount >= 1.0 ? maxampl :
                    (p->amount <= -1.0 ? -maxampl :
                    (p->amount * maxampl)));

    if (midpoint != -maxampl) 
        leftslope  = maxampl / (midpoint + maxampl);
    else leftslope  = 0.0;
    if (midpoint != maxampl)  
        rightslope = maxampl / (maxampl - midpoint);
    else rightslope = 0.0;

    cur = *in;
    if (cur < midpoint) *out = leftslope * (cur - midpoint);
    else *out = rightslope * (cur - midpoint);
    } else {
        SPFLOAT halfmaxampl = 0.5 * maxampl;
        midpoint =  (p->amount >= 1.0 ? maxampl :
                    (p->amount <= -1.0 ? 0.0 :
                    ((p->amount + 1.0) * halfmaxampl)));

        if (midpoint != 0.0) 
            leftslope = halfmaxampl / midpoint;
        else leftslope  = 0.0;
        if (midpoint != maxampl) 
            rightslope = halfmaxampl / (maxampl - midpoint);
        else rightslope = 0.0;

        cur = *in;
        if (cur < midpoint) { 
            *out = leftslope * cur;
        } else { 
            *out = rightslope * (cur - midpoint) + halfmaxampl;
        }
    }

    return SP_OK;
}
