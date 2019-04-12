/*
 * Talkbox
 * 
 * This module is ported from the mdaTalkbox plugin by Paul Kellet 
 * (maxim digital audio). 
 *
 * More information on his plugins and the original code can be found here:
 * 
 * http://mda.smartelectronix.com/ 
 * 
 */

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "soundpipe.h"

#ifndef TWO_PI
#define TWO_PI 6.28318530717958647692528676655901
#endif

#define ORD_MAX 50

static void lpc_durbin(SPFLOAT *r, int p, float *k, float *g)
{
  int i, j;
  SPFLOAT a[ORD_MAX], at[ORD_MAX], e=r[0];
    
  for(i=0; i<=p; i++) a[i] = at[i] = 0.0f;

  for(i=1; i<=p; i++) 
  {
    k[i] = -r[i];

    for(j=1; j<i; j++) 
    { 
      at[j] = a[j];
      k[i] -= a[j] * r[i-j]; 
    }
    if(fabs(e) < 1.0e-20f) { e = 0.0f;  break; }
    k[i] /= e;
    
    a[i] = k[i];
    for(j=1; j<i; j++) a[j] = at[j] + k[i] * at[i-j];
    
    e *= 1.0f - k[i] * k[i];
  }

  if(e < 1.0e-20f) e = 0.0f;
  *g = (float)sqrt(e);
}

static void lpc(float *buf, float *car, uint32_t n, uint32_t o)
{
    SPFLOAT z[ORD_MAX], r[ORD_MAX], k[ORD_MAX], G, x;
    uint32_t i, j, nn=n;
    SPFLOAT min;

    /* buf[] is already emphasized and windowed */
    for(j=0; j<=o; j++, nn--) {
        z[j] = r[j] = 0.0f;
        for(i=0; i<nn; i++) r[j] += buf[i] * buf[i+j]; /* autocorrelation */
    }

    r[0] *= 1.001f;  /* stability fix */
    
    min = 0.00001f;
    if(r[0] < min) { for(i=0; i<n; i++) buf[i] = 0.0f; return; } 

    lpc_durbin(r, o, k, &G);  /* calc reflection coeffs */

    for(i=1; i<=o; i++) {
        if(k[i] > 0.995f) k[i] = 0.995f; else if(k[i] < -0.995f) k[i] = -.995f;
    }

    for(i=0; i<n; i++) {
        x = G * car[i];
        /* lattice filter */
        for(j=o; j>0; j--) { 
            x -= k[j] * z[j-1];
            z[j] = z[j-1] + k[j] * x;
        }
        buf[i] = z[0] = x;  /* output buf[] will be windowed elsewhere */
    }
}

int sp_talkbox_create(sp_talkbox **p)
{
    *p = malloc(sizeof(sp_talkbox));
    return SP_OK;
}

int sp_talkbox_destroy(sp_talkbox **p)
{
    free(*p);
    return SP_OK;
}

int sp_talkbox_init(sp_data *sp, sp_talkbox *p)
{
    uint32_t n;
    p->quality = 1.f;
    p->N = 1;
    p->K = 0;

    n = (uint32_t)(0.01633f * sp->sr);
    if(n > SP_TALKBOX_BUFMAX) n = SP_TALKBOX_BUFMAX;

    /* calculate hanning window */
    if(n != p->N) {
        p->N = n;
        SPFLOAT dp = TWO_PI / (SPFLOAT)p->N;
        SPFLOAT pos = 0.0f;
        for(n=0; n < p->N; n++) {
            p->window[n] = 0.5f - 0.5f * (SPFLOAT)cos(pos);
            pos += dp;
        }
    }
 
    /* zero out variables and buffers */
    p->pos = p->K = 0;
    p->emphasis = 0.0f;
    p->FX = 0;

    p->u0 = p->u1 = p->u2 = p->u3 = p->u4 = 0.0f;
    p->d0 = p->d1 = p->d2 = p->d3 = p->d4 = 0.0f;

    memset(p->buf0, 0, SP_TALKBOX_BUFMAX * sizeof(SPFLOAT));
    memset(p->buf1, 0, SP_TALKBOX_BUFMAX * sizeof(SPFLOAT));
    memset(p->car0, 0, SP_TALKBOX_BUFMAX * sizeof(SPFLOAT));
    memset(p->car1, 0, SP_TALKBOX_BUFMAX * sizeof(SPFLOAT));
    return SP_OK;
}

int sp_talkbox_compute(sp_data *sp, sp_talkbox *t, SPFLOAT *src, SPFLOAT *exc, SPFLOAT *out)
{
    int32_t p0=t->pos, p1 = (t->pos + t->N/2) % t->N;
    SPFLOAT e=t->emphasis, w, o, x, fx=t->FX;
    SPFLOAT p, q, h0=0.3f, h1=0.77f;
    SPFLOAT den;

    t->O = (uint32_t)((0.0001f + 0.0004f * t->quality) * sp->sr);

    o = *src;
    x = *exc;

    p = t->d0 + h0 * x; 
    t->d0 = t->d1;  
    t->d1 = x - h0 * p;

    q = t->d2 + h1 * t->d4;
    t->d2 = t->d3;
    t->d3 = t->d4 - h1 * q;  

    t->d4 = x;

    x = p + q;

    if(t->K++) {
        t->K = 0;

        /* carrier input */
        t->car0[p0] = t->car1[p1] = x;

        /* 6dB/oct pre-emphasis */
        x = o - e;  e = o;  

        /* 50% overlapping hanning windows */
        w = t->window[p0]; fx = t->buf0[p0] * w;  t->buf0[p0] = x * w;  
        if(++p0 >= t->N) { lpc(t->buf0, t->car0, t->N, t->O);  p0 = 0; }

        w = 1.0f - w;  fx += t->buf1[p1] * w;  t->buf1[p1] = x * w;
        if(++p1 >= t->N) { lpc(t->buf1, t->car1, t->N, t->O);  p1 = 0; }
    }

    p = t->u0 + h0 * fx; 
    t->u0 = t->u1;  
    t->u1 = fx - h0 * p;

    q = t->u2 + h1 * t->u4;
    t->u2 = t->u3;
    t->u3 = t->u4 - h1 * q;  

    t->u4 = fx;
    x = p + q;

    o = x * 0.5;
    *out = o;
    t->emphasis = e;
    t->pos = p0;
    t->FX = fx;

    den = 1.0e-10f; 
    /* anti-denormal */
    if(fabs(t->d0) < den) t->d0 = 0.0f; 
    if(fabs(t->d1) < den) t->d1 = 0.0f;
    if(fabs(t->d2) < den) t->d2 = 0.0f;
    if(fabs(t->d3) < den) t->d3 = 0.0f;
    if(fabs(t->u0) < den) t->u0 = 0.0f;
    if(fabs(t->u1) < den) t->u1 = 0.0f;
    if(fabs(t->u2) < den) t->u2 = 0.0f;
    if(fabs(t->u3) < den) t->u3 = 0.0f;
    return SP_OK;
}
