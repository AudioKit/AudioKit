/*
  FFTwrapper.c  -  A wrapper for Fast Fourier Transforms
  Author: Nasca O. Paul, Tg. Mures, Romania

  De-classified and ported to C code by Paul Batchelor 2015

  License: Public Domain
  
  This requires FFTW library (http://www.fftw.org) to compile and run.
*/

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "soundpipe.h"
#include "kiss_fftr.h"

void FFTwrapper_create(FFTwrapper **fw, int fftsize) 
{
    *fw = malloc(sizeof(FFTwrapper));
    FFTwrapper *fwp = *fw;
    fwp->fftsize = fftsize;

#ifdef USE_FFTW3
    fftw_real *tf1 = malloc(fftsize * sizeof(fftw_real));
    fftw_real *tf2 = malloc(fftsize * sizeof(fftw_real)); 
    fwp->tmpfftdata1 = tf1; 
    fwp->tmpfftdata2 = tf2;
    fwp->planfftw = fftw_plan_r2r_1d(fftsize, fwp->tmpfftdata1, 
            fwp->tmpfftdata1, FFTW_R2HC, FFTW_ESTIMATE);
    fwp->planfftw_inv = fftw_plan_r2r_1d(fftsize, fwp->tmpfftdata2, 
            fwp->tmpfftdata2, FFTW_HC2R, FFTW_ESTIMATE);
#else
    fwp->fft = kiss_fftr_alloc(fftsize, 0, NULL, NULL);
    fwp->ifft = kiss_fftr_alloc(fftsize, 1, NULL, NULL);
    fwp->tmp1 = KISS_FFT_MALLOC(sizeof(kiss_fft_cpx) * fftsize);
    fwp->tmp2 = KISS_FFT_MALLOC(sizeof(kiss_fft_cpx) * fftsize);
    memset(fwp->tmp1, 0, sizeof(kiss_fft_cpx) * fftsize);
    memset(fwp->tmp2, 0, sizeof(kiss_fft_cpx) * fftsize);
#endif

}

void FFTwrapper_destroy(FFTwrapper **fw) 
{
    FFTwrapper *fwp = *fw;
#ifdef USE_FFTW3
    fftw_destroy_plan(fwp->planfftw);
    fftw_destroy_plan(fwp->planfftw_inv);
    free(fwp->tmpfftdata1);
    free(fwp->tmpfftdata2);
#else
    kiss_fftr_free(fwp->fft);
    kiss_fftr_free(fwp->ifft);
    KISS_FFT_FREE(fwp->tmp1);
    KISS_FFT_FREE(fwp->tmp2);
#endif
    free(*fw);
}

/* do the Fast Fourier Transform */

void smps2freqs(FFTwrapper *ft, SPFLOAT *smps, FFTFREQS *freqs) 
{
    int i;

#ifdef USE_FFTW3
    for (i = 0; i < ft->fftsize; i++) ft->tmpfftdata1[i]=smps[i];
    fftw_execute(ft->planfftw);

    for (i = 0; i < ft->fftsize/2; i++) {
        freqs.c[i] = ft->tmpfftdata1[i];
        if (i != 0) freqs.s[i] = ft->tmpfftdata1[ft->fftsize-i];
    }

    ft->tmpfftdata2[ft->fftsize/2] = 0.0;
#else
    kiss_fftr(ft->fft, smps, ft->tmp1);
    for (i = 0; i < ft->fftsize/2; i++) {
        freqs->c[i] = ft->tmp1[i].r;
        freqs->s[i] = ft->tmp1[i].i;
    }
#endif
}

/*
 * do the Inverse Fast Fourier Transform
 */
void freqs2smps(FFTwrapper *ft, FFTFREQS *freqs, SPFLOAT *smps) 
{

    int i;
#ifdef USE_FFTW3
    ft->tmpfftdata2[ft->fftsize/2]=0.0;
    for (i=0; i<ft->fftsize/2 ;i++) {
        ft->tmpfftdata2[i]=freqs.c[i];
        if (i != 0) ft->tmpfftdata2[ft->fftsize-i]=freqs.s[i];
    }
    fftw_execute(ft->planfftw_inv);
    for (i = 0; i < ft->fftsize; i++) smps[i]=ft->tmpfftdata2[i];
#else
    for(i = 0; i < ft->fftsize / 2; i++) {
        ft->tmp2[i].r = freqs->c[i];
        ft->tmp2[i].i = freqs->s[i];
    }
    kiss_fftri(ft->ifft, ft->tmp2, smps);
#endif

}

void newFFTFREQS(FFTFREQS *f,int size)
{
    int i;
    SPFLOAT *c = malloc(size * sizeof(SPFLOAT));
    SPFLOAT *s = malloc(size * sizeof(SPFLOAT));
    f->c = c;
    f->s = s;
    for (i = 0; i<size ;i++){
        f->c[i]=0.0;
        f->s[i]=0.0;
    };
}

void deleteFFTFREQS(FFTFREQS *f)
{
    free(f->c);
    free(f->s);
    f->c= f->s = NULL;
}
