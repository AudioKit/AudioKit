/*
 * Foo
 * 
 * This is a dummy module. It doesn't do much.
 * Feel free to use this as a boilerplate template.
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846	
#endif 

int sp_hilbert_create(sp_hilbert **p)
{
    *p = malloc(sizeof(sp_hilbert));
    return SP_OK;
}

int sp_hilbert_destroy(sp_hilbert **p)
{
    free(*p);
    return SP_OK;
}

int sp_hilbert_init(sp_data *sp, sp_hilbert *p)
{
    int j; 
    SPFLOAT onedsr = 1.0 / sp->sr;
    /* pole values taken from Bernie Hutchins, "Musical Engineer's Handbook" */
    SPFLOAT poles[12] = {0.3609, 2.7412, 11.1573, 44.7581, 179.6242, 798.4578,
                        1.2524, 5.5671, 22.3423, 89.6271, 364.7914, 2770.1114};
    SPFLOAT polefreq, rc, alpha, beta;
    /* calculate coefficients for allpass filters, based on sampling rate */
    for (j=0; j<12; j++) {
        polefreq = poles[j] * 15.0;
        rc = 1.0 / (2.0 * M_PI * polefreq);
        alpha = 1.0 / rc;
        alpha = alpha * 0.5 * onedsr;
        beta = (1.0 - alpha) / (1.0 + alpha);
        p->xnm1[j] = p->ynm1[j] = 0.0;
        p->coef[j] = -(SPFLOAT)beta;
    }
    return SP_OK;
}

int sp_hilbert_compute(sp_data *sp, sp_hilbert *p, SPFLOAT *in, SPFLOAT *out1, SPFLOAT *out2)
{
    SPFLOAT xn1 = 0;
    SPFLOAT yn1 = 0; 
    SPFLOAT xn2 = 0;
    SPFLOAT yn2 = 0;
    SPFLOAT *coef;
    int j;

    coef = p->coef;

    xn1 = *in;
    /* 6th order allpass filter for sine output. Structure is
    * 6 first-order allpass sections in series. Coefficients
    * taken from arrays calculated at i-time.
    */
    for (j=0; j < 6; j++) {
        yn1 = coef[j] * (xn1 - p->ynm1[j]) + p->xnm1[j];
        p->xnm1[j] = xn1;
        p->ynm1[j] = yn1;
        xn1 = yn1;
    }
    xn2 = *in;
    /* 6th order allpass filter for cosine output. Structure is
    * 6 first-order allpass sections in series. Coefficients
    * taken from arrays calculated at i-time.
    */
    for (j=6; j < 12; j++) {
        yn2 = coef[j] * (xn2 - p->ynm1[j]) + p->xnm1[j];
        p->xnm1[j] = xn2;
        p->ynm1[j] = yn2;
        xn2 = yn2;
    }
    *out1 = yn2;
    *out2 = yn1;
    return SP_OK;
}
