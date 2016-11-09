#include <math.h>
#include "soundpipe.h"
#include "kiss_fftr.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

int sp_gen_scrambler(sp_data *sp, sp_ftbl *src, sp_ftbl **dest)
{

    uint32_t size = (src->size % 2 == 0) ? (uint32_t)src->size : (uint32_t)src->size - 1;
    sp_ftbl *dst;
    sp_ftbl_create(sp, &dst, size);
    kiss_fftr_cfg fft, ifft;
    kiss_fft_cpx *tmp;

    /* set up kissfft */
    fft = kiss_fftr_alloc(size, 0, NULL, NULL);
    ifft = kiss_fftr_alloc(size, 1, NULL, NULL);
    tmp = malloc(sizeof(kiss_fft_cpx) * size);
    memset(tmp, 0, sizeof(SPFLOAT) * size);
    kiss_fftr(fft, src->tbl, tmp);

    uint32_t i;
    SPFLOAT mag, phs;
    for(i = 0; i < size / 2; i++) {
        mag = sqrt(tmp[i].r * tmp[i].r + tmp[i].i * tmp[i].i) / size;
        phs = ((SPFLOAT)sp_rand(sp) / SP_RANDMAX) * 2 * M_PI;
        tmp[i].r = mag * cos(phs);
        tmp[i].i = mag * sin(phs);
    }

    tmp[0].r = 0;
    tmp[0].i = 0;
    tmp[size / 2 - 1].r = 0;
    tmp[size / 2 - 1].i = 0;

    kiss_fftri(ifft, tmp, dst->tbl);
    SPFLOAT max = -1;
    SPFLOAT val = 0;
    for(i = 0; i < size; i++) {
        val = fabs(dst->tbl[i]); 
        if(val > max) {
            max = val;
        }
    }

    for(i = 0; i < size; i++) {
       dst->tbl[i] /= max;
    }

    kiss_fftr_free(fft);
    kiss_fftr_free(ifft);
    KISS_FFT_FREE(tmp);
    
    *dest = dst;
    return SP_OK;
}
