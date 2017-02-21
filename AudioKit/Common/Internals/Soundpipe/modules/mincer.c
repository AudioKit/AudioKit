/*
 * Mincer
 *
 * This code has been extracted from the Csound opcode "mincer".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author: Victor Lazzarini
 * Year: 2009
 * Location: OOps/pvlock.c
 *
 */

#include <math.h>
#include <stdlib.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846	
#endif
#include "soundpipe.h"

int sp_mincer_create(sp_mincer **p)
{
    *p = malloc(sizeof(sp_mincer));
    return SP_OK;
}

int sp_mincer_destroy(sp_mincer **p)
{
    sp_mincer *pp = *p;
    sp_fft_destroy(&pp->fft);
    sp_auxdata_free(&pp->fwin);
    sp_auxdata_free(&pp->bwin);
    sp_auxdata_free(&pp->prev);
    sp_auxdata_free(&pp->framecount);
    sp_auxdata_free(&pp->outframe);
    sp_auxdata_free(&pp->win);
    free(*p);
    return SP_OK;
}

static int find_power(int n) {
    int pow = -1;
    while(n > 0) {
        n >>= 1;
        pow++;
    }
    return pow;
}

int sp_mincer_init(sp_data *sp, sp_mincer *p, sp_ftbl *ft, int winsize)
{
    p->ft = ft;
    p->idecim = 4;
    p->iN = winsize;
    p->lock = 1;
    p->pitch = 1;
    p->amp = 1;
    p->time = 0;
    int N =  p->iN, ui;
    unsigned int size;
    int decim = p->idecim;
    int pow;

    /* find power to use for fft */
    
    pow = find_power(winsize);
    /* 2^11 = 2048, the default fftsize, will probably not change */
    sp_fft_init(&p->fft, pow);


    if (decim == 0) decim = 4;

    p->hsize = N/decim;
    p->cnt = p->hsize;
    p->curframe = 0;
    p->pos = 0;

    size = (N+2)*sizeof(SPFLOAT);
    sp_auxdata_alloc(&p->fwin, size);
    sp_auxdata_alloc(&p->bwin, size);
    sp_auxdata_alloc(&p->prev, size);
    size = decim*sizeof(int);
    sp_auxdata_alloc(&p->framecount, size);
    {
      int k=0;
        for (k=0; k < decim; k++) {
            ((int *)(p->framecount.ptr))[k] = k*N;
        }
    }
    size = decim*sizeof(SPFLOAT)*N;
    sp_auxdata_alloc(&p->outframe, size);
    
    size = N*sizeof(SPFLOAT);
    sp_auxdata_alloc(&p->win, size);
    {
        SPFLOAT x = 2.0 * M_PI/N;
        for (ui=0; ui < N; ui++)
        ((SPFLOAT *)p->win.ptr)[ui] = 0.5 - 0.5 * cos((SPFLOAT)ui*x);
    }

    p->N = N;
    p->decim = decim;

    return SP_OK;
}

int sp_mincer_compute(sp_data *sp, sp_mincer *p, SPFLOAT *in2, SPFLOAT *out)
{
    SPFLOAT pitch = p->pitch, time = p->time, lock = p->lock, amp =p->amp;
    SPFLOAT *tab, frac;
    sp_ftbl *ft = p->ft;
    int N = p->N, hsize = p->hsize, cnt = p->cnt;
    int sizefrs, size, post, i;
    long spos = p->pos;
    SPFLOAT pos;
    SPFLOAT *fwin, *bwin, insig = 0,
    *prev, *win = (SPFLOAT *) p->win.ptr;
    SPFLOAT *outframe;
    SPFLOAT ph_real, ph_im, tmp_real, tmp_im, divi;
    int *framecnt;
    int curframe = p->curframe, decim = p->decim;
    SPFLOAT scaling = (8./decim)/3.;

    if (cnt == hsize) {
        tab = ft->tbl;
        size = (int)ft->size;

        /* spos is the reading position in samples, hsize is hopsize,
        time[n] is current read position in secs
        esr is sampling rate
        */
        spos  = hsize*(long)((time)*sp->sr/hsize);
        sizefrs = size;
        while(spos > sizefrs) spos -= sizefrs;
        while(spos <= 0)  spos += sizefrs;


        pos = spos;
        bwin = (SPFLOAT *) p->bwin.ptr;
        fwin = (SPFLOAT *) p->fwin.ptr;
        prev = (SPFLOAT *)p->prev.ptr;
        framecnt  = (int *)p->framecount.ptr;
        outframe= (SPFLOAT *) p->outframe.ptr;
        /* this loop fills two frames/windows with samples from table,
        reading is linearly-interpolated,
        frames are separated by 1 hopsize
        */
        for (i=0; i < N; i++) {
            /* front window, fwin */
            post = (int) pos;
            frac = pos  - post;
            while (post < 0) post += size;
            while (post >= size) post -= size;
            if(post + 1 <  size)
            insig = tab[post] + frac*(tab[post+ 1] - tab[post]);
            else insig = tab[post];

            /* window it */
            fwin[i] = insig * win[i]; 
            /* back windo, bwin */
            post = (int) (pos - hsize*pitch);
            post *= 1;
            post += 0;
            while(post < 0) post += size;
            while(post >= size) post -= size;
            if(post + 1<  size)
            insig = tab[post] + frac*(tab[post + 1] - tab[post]);
            else insig = tab[post];
            bwin[i] = insig * win[i];  /* window it */
            /* increment read pos according to pitch transposition */
            pos += pitch;
        }

        /* take the FFT of both frames
        re-order Nyquist bin from pos 1 to N
        */
        sp_fftr(&p->fft, bwin, N);
        bwin[N] = bwin[1];
        bwin[N+1] = 0.0;
        sp_fftr(&p->fft, fwin, N);
        fwin[N] = fwin[1];
        fwin[N+1] = 0.0;

        /* phase vocoder processing */

        for (i=0; i < N + 2; i+=2) {
            /* phases of previous output frame in exponential format,
            obtained by dividing by magnitude */
            divi =  1.0/(hypot(prev[i], prev[i+1]) + 1e-20);
            ph_real  =    prev[i]*divi;
            ph_im =       prev[i+1]*divi;

            /* back window magnitudes, phase differences between
            prev and back windows */
            tmp_real =   bwin[i] * ph_real + bwin[i+1] * ph_im;
            tmp_im =   bwin[i] * ph_im - bwin[i+1] * ph_real;
            bwin[i] = tmp_real;
            bwin[i+1] = tmp_im;
        }

        for (i=0; i < N + 2; i+=2) {
            if (lock) {  /* phase-locking */
                if (i > 0) {
                    if (i < N){
                        tmp_real = bwin[i] + bwin[i-2] + bwin[i+2];
                        tmp_im = bwin[i+1] + bwin[i-1] + bwin[i+3];
                    } else { /* Nyquist */
                        tmp_real = bwin[i] + bwin[i-2];
                        tmp_im = 0.0;
                    } 
                } else { /* 0 Hz */
                    tmp_real = bwin[i] + bwin[i+2];
                    tmp_im = 0.0;
                }
            } else { /* no locking */
                tmp_real = bwin[i];
                tmp_im = bwin[i+1];
            }

            tmp_real += 1e-15;
            divi =  1.0/(hypot(tmp_real, tmp_im));

            /* phases of tmp frame */
            ph_real = tmp_real*divi;
            ph_im = tmp_im*divi;

            /* front window mags, phase sum of
            tmp and front windows */
            tmp_real =   fwin[i] * ph_real - fwin[i+1] * ph_im;
            tmp_im =   fwin[i] * ph_im + fwin[i+1] * ph_real;

            /* phase vocoder output */
            prev[i] = fwin[i] = tmp_real;
            prev[i+1] = fwin[i+1] = tmp_im;
        }
        /* re-order bins and take inverse FFT */
        fwin[1] = fwin[N];
        sp_ifftr(&p->fft, fwin, N);
        /* frame counter */
        framecnt[curframe] = curframe*N;
        /* write to overlapped output frames */
        for (i=0;i<N;i++) outframe[framecnt[curframe]+i] = win[i]*fwin[i];

        cnt=0;
        curframe++;
        if (curframe == decim) curframe = 0;
    }

    framecnt  = (int *) p->framecount.ptr;
    outframe  = (SPFLOAT *) p->outframe.ptr;
    *out = (SPFLOAT)0;
    /* write output */
    for (i = 0; i < decim; i++) {
        *out += outframe[framecnt[i]];
        framecnt[i]++;
    }
    /* scale output */
    *out *= amp*scaling;
    cnt++;

    p->cnt = cnt;
    p->curframe = curframe;

    return SP_OK;
}
