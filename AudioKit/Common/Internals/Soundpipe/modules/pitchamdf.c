/*
 * pitchamdf
 *
 * This code has been extracted from the Csound opcode "pitchamdf".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Peter Neubacker
 * Year: 1999
 * Location: Opcodes/pitch.c
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

/* #define lrintf(x) lrintf(x) */

int sp_pitchamdf_create(sp_pitchamdf **p)
{
    *p = malloc(sizeof(sp_pitchamdf));
    return SP_OK;
}

int sp_pitchamdf_destroy(sp_pitchamdf **p)
{
    sp_pitchamdf *pp = *p;
    sp_auxdata_free(&pp->median);
/* This mirrors the original code */
    if(pp->rmsmedisize) {
        sp_auxdata_free(&pp->rmsmedian);
    }
    sp_auxdata_free(&pp->buffer);
    free(*p);
    return SP_OK;
}

int sp_pitchamdf_init(sp_data *sp, sp_pitchamdf *p, SPFLOAT imincps, SPFLOAT imaxcps)
{
    SPFLOAT srate, downs;
    int32_t size, minperi, maxperi, downsamp, upsamp, msize, bufsize;
    uint32_t interval;

    p->imincps = imincps;
    p->imaxcps = imaxcps;

    /* TODO: should we expose these variables? */
    p->icps = 0;
    p->imedi = 1;
    p->idowns = 1;
    p->iexcps = 0;
    p->irmsmedi = 0;

    p->inerr = 0;
    downs = p->idowns;

    if (downs < (-1.9)) {
        upsamp = (int)lrintf((-downs));
        downsamp = 0;
        srate = sp->sr * (SPFLOAT)upsamp;
    } else {
        downsamp = (int)lrintf(downs);
        if (downsamp < 1) downsamp = 1;
        srate = sp->sr / (SPFLOAT)downsamp;
        upsamp = 0;
    }

    minperi = (int32_t)(srate / p->imaxcps);
    maxperi = (int32_t)(0.5 + srate / p->imincps);
    if (maxperi <= minperi) {
        p->inerr = 1;
        return SP_NOT_OK;
    }

    if (p->iexcps < 1)
        interval = maxperi;
    else
        interval = (uint32_t)(srate / p->iexcps);

    size = maxperi + interval;
    bufsize = sizeof(SPFLOAT)*(size + maxperi + 2);

    p->srate = srate;
    p->downsamp = downsamp;
    p->upsamp = upsamp;
    p->minperi = minperi;
    p->maxperi = maxperi;
    p->size = size;
    p->readp = 0;
    p->index = 0;
    p->lastval = 0.0;

    if (p->icps < 1) {
        p->peri = (minperi + maxperi) / 2;
    } else {
        p->peri = (int)(srate / p->icps);
    }

    if (p->irmsmedi < 1) {
        p->rmsmedisize = 0;
    } else {
        p->rmsmedisize = ((int)lrintf(p->irmsmedi))*2+1;
    }

    p->rmsmediptr = 0;

    if (p->rmsmedisize) {
        msize = p->rmsmedisize * 3 * sizeof(SPFLOAT);
        sp_auxdata_alloc(&p->rmsmedian, msize);
    }

    if (p->imedi < 1) {
        p->medisize = 0;
    } else {
        p->medisize = (int)lrintf(p->imedi) * 2 + 1;
    }

    p->mediptr = 0;

    if (p->medisize) {
        msize = p->medisize * 3 * sizeof(SPFLOAT);
        sp_auxdata_alloc(&p->median, msize);
    }

    sp_auxdata_alloc(&p->buffer, bufsize);
    return SP_OK;
}


#define SWAP(a,b) temp=(a);(a)=(b);(b)=temp

static SPFLOAT medianvalue(uint32_t n, SPFLOAT *vals)
{   
    /* vals must point to 1 below relevant data! */
    uint32_t i, ir, j, l, mid;
    uint32_t k = (n + 1) / 2;
    SPFLOAT a, temp;

    l = 1;
    ir = n;
    while (1) {
        if (ir <= l+1) {
            if (ir == l+1 && vals[ir] < vals[l]) {
                SWAP(vals[l], vals[ir]);
            }
            return vals[k];
        } else {
            mid = (l+ir) >> 1;
            SWAP(vals[mid], vals[l+1]);
            if (vals[l+1] > vals[ir]) {
                SWAP(vals[l+1], vals[ir]);
            }
            if (vals[l] > vals[ir]) {
                SWAP(vals[l], vals[ir]);
            }
            if (vals[l+1] > vals[l]) {
                SWAP(vals[l+1], vals[l]);
            }
            i = l + 1;
            j = ir;
            a = vals[l];
            while (1) {
                do i++; while (vals[i] < a);
                do j--; while (vals[j] > a);
                if (j < i) break;
                SWAP(vals[i], vals[j]);
            }
            vals[l] = vals[j];
            vals[j] = a;
            if (j >= k) ir = j-1;
            if (j <= k) l = i;
        }
    }
}
#undef SWAP

int sp_pitchamdf_compute(sp_data *sp, sp_pitchamdf *p, SPFLOAT *in, 
    SPFLOAT *cps, SPFLOAT *rms_out)
{
    SPFLOAT *buffer = (SPFLOAT*)p->buffer.ptr;
    SPFLOAT *rmsmedian = (SPFLOAT*)p->rmsmedian.ptr;
    int32_t rmsmedisize = p->rmsmedisize;
    int32_t rmsmediptr = p->rmsmediptr;
    SPFLOAT *median = (SPFLOAT*)p->median.ptr;
    int32_t medisize = p->medisize;
    int32_t mediptr = p->mediptr;
    int32_t size = p->size;
    int32_t index = p->index;
    int32_t minperi = p->minperi;
    int32_t maxperi = p->maxperi;
    SPFLOAT srate = p->srate;
    int32_t peri = p->peri;
    int32_t upsamp = p->upsamp;
    SPFLOAT upsmp = (SPFLOAT)upsamp;
    SPFLOAT lastval = p->lastval;
    SPFLOAT newval, delta;
    int32_t readp = p->readp;
    int32_t interval = size - maxperi;
    int i;
    int32_t i1, i2;
    SPFLOAT val, rms;
    SPFLOAT sum;
    SPFLOAT acc, accmin, diff;

    if (upsamp) {
        newval = *in;
        delta = (newval-lastval) / upsmp;
        lastval = newval;

        for (i=0; i<upsamp; i++) {
            newval += delta;
            buffer[index++] = newval;

            if (index == size) {
                peri = minperi;
                accmin = 0.0;
                for (i2 = 0; i2 < size; ++i2) {
                    diff = buffer[i2+minperi] - buffer[i2];
                    if (diff > 0) accmin += diff;
                    else accmin -= diff;
                }
                for (i1 = minperi + 1; i1 <= maxperi; ++i1) {
                    acc = 0.0;
                    for (i2 = 0; i2 < size; ++i2) {
                        diff = buffer[i1+i2] - buffer[i2];
                        if (diff > 0) acc += diff;
                        else acc -= diff;
                    }
                    if (acc < accmin) {
                        accmin = acc;
                        peri = i1;
                    }
                }

                for (i1 = 0; i1 < interval; i1++) { 
                    buffer[i1] = buffer[i1+interval]; 
                }

                index = maxperi;

                if (medisize) {
                    median[mediptr] = (SPFLOAT)peri;
                    for (i1 = 0; i1 < medisize; i1++) {
                        median[medisize+i1] = median[i1];
                    }

                    median[medisize*2+mediptr] =
                    medianvalue(medisize, &median[medisize-1]);
                    peri = (int32_t)median[medisize*2 +
                        ((mediptr+medisize/2+1) % medisize)];

                    mediptr = (mediptr + 1) % medisize;
                    p->mediptr = mediptr;
                }
            }
        }
        p->lastval = lastval;
    } else {
        int32_t  downsamp = p->downsamp;
        buffer[index++] = *in;
        readp += downsamp;

        if (index == size) {
            peri = minperi;
            accmin = 0.0;

            for (i2 = 0; i2 < size; ++i2) {
                diff = buffer[i2+minperi] - buffer[i2];
                if (diff > 0.0) accmin += diff;
                else accmin -= diff;
            }

            for (i1 = minperi + 1; i1 <= maxperi; ++i1) {
                acc = 0.0;
                for (i2 = 0; i2 < size; ++i2) {
                    diff = buffer[i1+i2] - buffer[i2];
                    if (diff > 0.0) acc += diff;
                    else acc -= diff;
                }
                if (acc < accmin) {
                    accmin = acc;
                    peri = i1;
                }
            }

            for (i1 = 0; i1 < interval; i1++) {
                buffer[i1] = buffer[i1+interval];
            }

            index = maxperi;

            if (medisize) {
                median[mediptr] = (SPFLOAT)peri;

                for (i1 = 0; i1 < medisize; i1++) {
                    median[medisize+i1] = median[i1];
                }

                median[medisize*2+mediptr] =
                medianvalue(medisize, &median[medisize-1]);
                peri = (int32_t)median[medisize*2 +
                    ((mediptr+medisize/2+1) % medisize)];

                mediptr = (mediptr + 1) % medisize;
                p->mediptr = mediptr;
            }
        }
    }
    buffer = &buffer[(index + size - peri) % size];
    sum = 0.0;
    for (i1=0; i1<peri; i1++) {
        val = buffer[i1];
        sum += (SPFLOAT)(val * val);
    }
    if (peri==0)      
        rms = 0.0;
    else
        rms = (SPFLOAT)sqrt(sum / (SPFLOAT)peri);
    if (rmsmedisize) {
        rmsmedian[rmsmediptr] = rms;
        for (i1 = 0; i1 < rmsmedisize; i1++) {
            rmsmedian[rmsmedisize+i1] = rmsmedian[i1];
        }

        rmsmedian[rmsmedisize*2+rmsmediptr] =
            medianvalue(rmsmedisize, &rmsmedian[rmsmedisize-1]);
        rms = rmsmedian[rmsmedisize*2 +
            ((rmsmediptr+rmsmedisize/2+1) % rmsmedisize)];

        rmsmediptr = (rmsmediptr + 1) % rmsmedisize;
        p->rmsmediptr = rmsmediptr;
    }

    if (peri==0) {
        *cps = 0.0;
    } else {
        *cps = srate / (SPFLOAT)peri;
    }

    *rms_out = rms;
    p->index = index;
    p->peri = peri;
    p->readp = readp;
    return SP_OK;
}
