/*
 * Bar
 *
 * This code has been extracted from the Csound opcode "bilbar".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Stefan Bilbao, John Ffitch
 * Year: 2006
 * Location: Opcodes/bilbar.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif


int sp_bar_create(sp_bar **p)
{
    *p = malloc(sizeof(sp_bar));
    return SP_OK;
}

int sp_bar_destroy(sp_bar **p)
{
    sp_bar *pp = *p;
    sp_auxdata_free(&pp->w_aux);
    free(*p);
    return SP_OK;
}

int sp_bar_init(sp_data *sp, sp_bar *p, SPFLOAT iK, SPFLOAT ib)
{
    p->bcL = 1;
    p->bcR = 1;
    p->iK = iK;
    p->ib = ib;
    p->scan = 0.23;
    p->T30 = 3;
    p->pos = 0.2;
    p->vel = 500;
    p->wid = 0.05;

    SPFLOAT K = p->iK;       /* ~=3.0  stiffness parameter, dimensionless */
    SPFLOAT T30 = p->T30;   /* ~=5.0; 30 db decay time (s) */
    SPFLOAT b = p->ib;       /* ~=0.001 high-frequency loss parameter
                               (keep small) */

    /* derived parameters */
    SPFLOAT dt = 1.0 / sp->sr;
    SPFLOAT sig = (2.0 * sp->sr) * (pow(10.0, 3.0 * dt / T30) - 1.0);
    SPFLOAT dxmin = sqrt(dt * (b+hypot(b, K+K) ));
    int N = (int) (1.0/dxmin);
    SPFLOAT dx = 1.0/N;

    /* scheme coefficients */
    p->s0 = (2.0-6.0*K*K*dt*dt/(dx*dx*dx*dx)-2.0*b*dt/(dx*dx))/(1.0+sig*dt*0.5);
    p->s1 = (4.0*K*K*dt*dt/(dx*dx*dx*dx)+b*dt/(dx*dx))/(1.0+sig*dt*0.5);
    p->s2 = -K*K*dt*dt/((dx*dx*dx*dx)*(1.0+sig*dt*0.5));
    p->t0 = (-1.0+2.0*b*dt/(dx*dx)+sig*dt*0.5)/(1.0+sig*dt*0.5);
    p->t1 = (-b*dt)/(dx*dx*(1.0+sig*dt*0.5));

    sp_auxdata_alloc(&p->w_aux, (size_t) 3 * ((N + 5) * sizeof(SPFLOAT)));
    p->w = (SPFLOAT *) p->w_aux.ptr;
    p->w1 = &(p->w[N + 5]);
    p->w2 = &(p->w1[N + 5]);
    p->step = p->first = 0;
    p->N = N;
    p->first = 0;
    return SP_OK;
}

int sp_bar_compute(sp_data *sp, sp_bar *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT xofreq = 2 * M_PI * (p->scan)/sp->sr;
    SPFLOAT xo, xofrac;
    int xoint;
    int step = p->step;
    int first = p->first;
    int N = p->N, rr;
    SPFLOAT *w = p->w, *w1 = p->w1, *w2 = p->w2;
    SPFLOAT s0 = p->s0, s1 = p->s1, s2 = p->s2, t0 = p->t0, t1 = p->t1;
    int bcL = (int)lrintf((SPFLOAT)p->bcL);
    int bcR = (int)lrintf((SPFLOAT)p->bcR);
    SPFLOAT SINNW = sin(xofreq*step);
    SPFLOAT COSNW = cos(xofreq*step);
    SPFLOAT SIN1W = sin(xofreq);
    SPFLOAT COS1W = cos(xofreq);

    if(*in) {
        p->first = 0;
        SPFLOAT K = p->iK;
        SPFLOAT T30 = p->T30;
        SPFLOAT b = p->ib;

        SPFLOAT dt = 1.0 / sp->sr;
        SPFLOAT sig = (2.0 * sp->sr) * (pow(10.0, 3.0 * dt / T30) - 1.0);
        SPFLOAT dxmin = sqrt(dt * (b+hypot(b, K+K) ));
        int N = (int) (1.0/dxmin);
        SPFLOAT dx = 1.0/N;

        p->s0 = (2.0-6.0*K*K*dt*dt/(dx*dx*dx*dx)-2.0*b*dt/(dx*dx))/(1.0+sig*dt*0.5);
        p->s1 = (4.0*K*K*dt*dt/(dx*dx*dx*dx)+b*dt/(dx*dx))/(1.0+sig*dt*0.5);
        p->s2 = -K*K*dt*dt/((dx*dx*dx*dx)*(1.0+sig*dt*0.5));
        p->t0 = (-1.0+2.0*b*dt/(dx*dx)+sig*dt*0.5)/(1.0+sig*dt*0.5);
        p->t1 = (-b*dt)/(dx*dx*(1.0+sig*dt*0.5));

        s0 = p->s0, s1 = p->s1, s2 = p->s2, t0 = p->t0, t1 = p->t1;
    }

    if ((bcL|bcR)&(~3) && (bcL|bcR)!=0) {
        fprintf(stderr,
                "sp_bar: Ends must be clamped(1), pivoting(2), or free(3)\n");
        return SP_NOT_OK;
    }

    if (bcL == 3) {
        w1[1] = 2.0*w1[2]-w1[3];
        w1[0] = 3.0*w1[1]-3.0*w1[2]+w1[3];
    }
    else if (bcL == 1) {
        w1[2] = 0.0;
        w1[3] = 0.0;
    }
    else if (bcL == 2) {
        w1[2] = 0.0;
        w1[1] = -w1[3];
    }

    if (bcR == 3) {
        w1[N+3] = 2.0*w1[N+2]-w1[N+1];
        w1[N+4] = 3.0*w1[N+3]-3.0*w1[N+2]+w1[N+1];
    } else if (bcR == 1) {
        w1[N+1] = 0.0;
        w1[N+2] = 0.0;
    } else if (bcR == 2) {
        w1[N+2] = 0.0;
        w1[N+3] = -w1[N+1];
    }

    /* Iterate model */
    for (rr = 0; rr < N+1; rr++) {
        w[rr+2] = s0*w1[rr+2] + s1*(w1[rr+3]+w1[rr+1]) + s2*(w1[rr+4]+w1[rr]) +
                  t0*w2[rr+2] + t1*(w2[rr+3]+w2[rr+1]);
    }

    /*  strike inputs */

    if (first == 0) {
        p->first = first = 1;
        for (rr = 0; rr < N; rr++) {
            if (fabs(rr/(SPFLOAT)N - p->pos) <= p->wid) {
                w[rr+2] += (1.0/sp->sr)*(p->vel)*0.5*
                    (1.0+cos(M_PI*fabs(rr/(SPFLOAT)N-(p->pos))/(p->wid)));
            }
        }
    }
    {
        SPFLOAT xx = SINNW*COS1W + COSNW*SIN1W;
        SPFLOAT yy = COSNW*COS1W - SINNW*SIN1W;

        SINNW = xx;
        COSNW = yy;
    }
    xo = 0.5 + 0.5*SINNW;
    xoint = (int) (xo*N) + 2;
    xofrac = xo*N - (int)(xo*N);

    *out = ((1.0-xofrac)*w[xoint] + xofrac*w[xoint+1]);
    step++;
    {
        SPFLOAT *ww = w2;

        w2 = w1;
        w1 = w;
        w = ww;
    }
    p->step = step;
    p->w = w;
    p->w1 = w1;
    p->w2 = w2;
    return SP_OK;
}
