/*
 * Clip
 * 
 * This code has been extracted from the Csound opcode "clip".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): John ffitch, Istvan Varga, Peter Neubäcker,
                       rasmus ekman, Phil Burk
 * Year: 1999
 * Location: Opcodes/pitch.c
 *
 */

#include <math.h>
#include <stdint.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif 

#include "soundpipe.h"

static void set_meth(sp_clip *p)
{
    switch (p->meth) {
        case 0: /* Bram de Jong method */
            if (p->arg > 1.0 || p->arg < 0.0) p->arg = 0.999;
            p->arg = p->lim * p->arg;
            p->k1 = 1.0 / (p->lim - p->arg);
            p->k1 = p->k1 * p->k1;
            p->k2 = (p->lim + p->arg) * 0.5;
            break;
        case 1: /* Sine method */
            p->k1 = M_PI / (2.0 * p->lim);
            break;
        case 2: /* tanh method */
            p->k1 = 1.0 / tanh(1.0);
            break;
        default:
            p->meth = 0;
    }
}

int sp_clip_create(sp_clip **p)
{
    *p = malloc(sizeof(sp_clip));
    return SP_OK;
}

int sp_clip_destroy(sp_clip **p)
{
    free(*p);
    return SP_OK;
}

int sp_clip_init(sp_data *sp, sp_clip *p)
{
    p->meth = 1;
    p->pmeth = 1;
    p->arg = 0.5;
    p->lim = 1;
    set_meth(p);
    return SP_OK;
}

int sp_clip_compute(sp_data *sp, sp_clip *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT a = p->arg, k1 = p->k1, k2 = p->k2;
    SPFLOAT limit = p->lim;
    SPFLOAT rlim = 1.0 / limit;
    SPFLOAT x;

    if(p->meth != p->pmeth) {
        p->pmeth = p->meth;
        set_meth(p);
    }

    switch (p->meth) {
        case 0:                     /* Soft clip with division */
            x = *in;
            if (x >= 0.0) {
                if (x > limit) x = k2;
                else if (x > a){
                    x = a + (x - a) / (1.0 + (x - a) * (x - a) * k1);
                }
            } else {
                if (x < -limit) {
                    x = -k2;
                } else if (-x > a) {
                    x = -a + (x + a) / (1.0 + (x + a) * (x + a) * k1);
                }
            }
            *out = x;

            return SP_OK;
        case 1:
            x = *in;
            if (x >= limit) {
                x = limit;
            } else if (x <= -limit)
              x = -limit;
            else{
                x = limit * sin(k1 * x);
            }
            *out = x;
          
            return SP_OK;
        case 2:
            x = *in;
            if (x >= limit){
              x = limit;
            } else if (x <= -limit){
              x = -limit;
            }
            else{
              x = limit * k1 * tanh(x * rlim);
            }
            *out = x;
            return SP_OK;
        }

    p->pmeth = p->meth;
    return SP_OK;
}
