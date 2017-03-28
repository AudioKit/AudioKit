/*
 * RSpline
 *
 * This code has been extracted from the Csound opcode "rspline".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Gabriel Maldonado, John FFitch
 * Year: 1998
 * Location: OOps/uggab.c
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

#define sp_oneUp31Bit      (4.656612875245796924105750827168e-10)
#define sp_randGab   ((SPFLOAT)     \
        (((p->holdrand = p->holdrand * 214013 + 2531011) >> 1)  \
         & 0x7fffffff) * sp_oneUp31Bit)
#define sp_BiRandGab ((SPFLOAT)     \
        (p->holdrand = p->holdrand * -214013 + 2531011) * sp_oneUp31Bit)

int sp_rspline_create(sp_rspline **p)
{
    *p = malloc(sizeof(sp_rspline));
    return SP_OK;
}

int sp_rspline_destroy(sp_rspline **p)
{
    free(*p);
    return SP_OK;
}

int sp_rspline_init(sp_data *sp, sp_rspline *p)
{
    p->holdrand = sp_rand(sp);
    p->num1 = sp_randGab;
    p->num2 = sp_randGab;
    p->df1 = 0.0;
    p->phs = 0.0;
    p->init = 1;
    p->cps_max = 3;
    p->cps_min = 0.1;
    p->min = 0;
    p->max = 1;
    p->onedsr = 1.0 / (SPFLOAT)sp->sr;
    return SP_OK;
}

int sp_rspline_compute(sp_data *sp, sp_rspline *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT x;
    SPFLOAT f0 = p->num0, df0 = p->df0;
    SPFLOAT phs = p->phs;
    SPFLOAT slope, resd1, resd0, f2, f1;

    /* the original source code used an init flag alongside a goto */
    /* I didn't want to use gotos, so I opted to use this approach */

    if(p->init) {
        p->si = (sp_randGab * (p->cps_max - p->cps_min) + p->cps_min)*p->onedsr;
        p->init = 1;
    }

    phs += p->si;
    if (phs >= 1.0 || p->init) {
        p->si = (sp_randGab * (p->cps_max - p->cps_min)+p->cps_min)*p->onedsr;
        while (phs > 1.0) phs -= 1.0;
        f0 = p->num0 = p->num1;
        f1 = p->num1 = p->num2;
        f2 = p->num2 = sp_BiRandGab;
        df0 = p->df0 = p->df1;
        p->df1 = (f2 - f0) * 0.5;
        slope = f1 - f0;
        resd0 = df0 - slope;
        resd1 = p->df1 - slope;
        p->c3 = resd0 + resd1;
        p->c2 = - (resd1 + 2.0 * resd0);
    }

    x = (SPFLOAT) phs;
    *out = (((p->c3 * x + p->c2) * x + df0) * x + f0) * 
        (p->max - p->min) + p->min;
    p->phs = phs;
    p->init = 0;
    return SP_OK;
}
