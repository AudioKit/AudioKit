#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

#define SQRT2 1.41421356237309504880


int sp_panst_create(sp_panst **p)
{
    *p = malloc(sizeof(sp_panst));
    return SP_OK;
}

int sp_panst_destroy(sp_panst **p)
{
    free(*p);
    return SP_OK;
}

int sp_panst_init(sp_data *sp, sp_panst *p)
{
    p->type = 0;
    p->pan = 0;
    return SP_OK;
}

int sp_panst_compute(sp_data *sp, sp_panst *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out1, SPFLOAT *out2)
{
    /* Send the signal's input to the output */
    uint32_t type = p->type;
    SPFLOAT pan = (p->pan + 1.0) * 0.5;
    SPFLOAT cc, ss, l, r;

    type %= 4;

    switch (type) {
        /* Equal power */
        case 0:
        pan = M_PI * 0.5 * pan;
        *out1 = *in1 * cos(pan);
        *out2 = *in2 * sin(pan);
        break;

        /* Square root */
        case 1:
        *out1 = *in1 * sqrt(pan);
        *out2 = *in2 * sqrt(1.0 - pan);
        break;

        /* simple linear */
        case 2:
        *out1 = *in1 * (1.0 - pan);
        *out2 = *in2 * pan;
        break;

        /* Equal power (alternative) */
        case 3:

        cc = cos(M_PI * pan * 0.5);
        ss = sin(M_PI * pan * 0.5);
        l = SQRT2 * (cc + ss) * 0.5;
        r = SQRT2 * (cc - ss) * 0.5;
        *out1 = *in1 * l;
        *out2 = *in2 * r;
        break;
    }

    return SP_OK;
}
