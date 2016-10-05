/*
    Example implementation of the PADsynth basic algorithm
    By: Nasca O. Paul, Tg. Mures, Romania

    Ported to pure C by Paul Batchelor

    This implementation and the algorithm are released under Public Domain
    Feel free to use it into your projects or your products ;-)

    This implementation is tested under GCC/Linux, but it's 
    very easy to port to other compiler/OS.
*/

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846	
#endif 

int sp_gen_padsynth(sp_data *sp, sp_ftbl *ps, sp_ftbl *amps, 
        SPFLOAT f, SPFLOAT bw) 
{

    int i, nh;
    int N = (int) ps->size;
    int number_harmonics = (int) amps->size;
    SPFLOAT *A = amps->tbl;
    SPFLOAT *smp = ps->tbl;

    SPFLOAT *freq_amp = malloc((N / 2) * sizeof(SPFLOAT));
    SPFLOAT *freq_phase = malloc((N / 2) * sizeof(SPFLOAT));

    for (i=0;i<N/2;i++) freq_amp[i]=0.0;

    for (nh=1;nh<number_harmonics;nh++) {
        SPFLOAT bw_Hz;
        SPFLOAT bwi;
        SPFLOAT fi;
        bw_Hz = (pow(2.0, bw/1200.0) - 1.0) * f * nh;

        //bwi = bw_Hz/(2.0*sp->sr);
        //fi = f*nh/sp->sr;
        bwi = bw_Hz/(2.0*ps->size);
        fi = f*nh/ps->size;
        for (i = 0; i < N/2 ; i++) {
            SPFLOAT hprofile;
            hprofile = sp_padsynth_profile((i / (SPFLOAT) N) - fi, bwi);
            freq_amp[i] += hprofile*A[nh];
        }
    }

    for (i=0;i<N/2;i++) {
        freq_phase[i]= (sp_rand(sp) / (RAND_MAX + 1.0)) * 2.0 * M_PI;
    };

    sp_padsynth_ifft(N,freq_amp,freq_phase,smp);
    sp_padsynth_normalize(N,smp);

    free(freq_amp);
    free(freq_phase);
    return SP_OK;
}

/* This is the profile of one harmonic
   In this case is a Gaussian distribution (e^(-x^2))
   The amplitude is divided by the bandwidth to ensure that the harmonic
   keeps the same amplitude regardless of the bandwidth */

SPFLOAT sp_padsynth_profile(SPFLOAT fi, SPFLOAT bwi) 
{
    SPFLOAT x =fi/bwi;
    x *= x;

/* 
 * this avoids computing the e^(-x^2) where 
 * it's results are very close to zero
 */
    if (x>14.71280603) return 0.0;

    return exp(-x)/bwi;
}

int sp_padsynth_ifft(int N, SPFLOAT *freq_amp, 
        SPFLOAT *freq_phase, SPFLOAT *smp) 
{
    int i;
    FFTwrapper *fft;
    FFTwrapper_create(&fft, N);
    FFTFREQS fftfreqs;
    newFFTFREQS(&fftfreqs,N/2);

    for (i=0; i<N/2; i++){
        fftfreqs.c[i]=freq_amp[i]*cos(freq_phase[i]);
        fftfreqs.s[i]=freq_amp[i]*sin(freq_phase[i]);
    };
    freqs2smps(fft, &fftfreqs,smp);
    deleteFFTFREQS(&fftfreqs);
    FFTwrapper_destroy(&fft);
    return SP_OK;
}

/*
    Simple normalization function. It normalizes the sound to 1/sqrt(2)
*/

int sp_padsynth_normalize(int N, SPFLOAT *smp) 
{
    int i;
    SPFLOAT max=0.0;
    for (i=0;i<N;i++) if (fabs(smp[i])>max) max=fabs(smp[i]);
    if (max<1e-5) max=1e-5;
    for (i=0;i<N;i++) smp[i]/=max*1.4142;
    return SP_OK;
}
