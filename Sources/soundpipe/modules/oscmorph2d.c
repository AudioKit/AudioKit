#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_oscmorph2d_create(sp_oscmorph2d **p)
{
    *p = malloc(sizeof(sp_oscmorph2d));
    return SP_OK;
}

int sp_oscmorph2d_destroy(sp_oscmorph2d **p)
{
    free(*p);
    return SP_OK;
}

int sp_oscmorph2d_init(sp_data *sp, sp_oscmorph2d *osc, sp_ftbl **ft, int nft, int nbl, float *fbls, SPFLOAT iphs)
{
    int i;
    osc->freq = 440.0;
    osc->amp = 0.2;
    osc->tbl = ft;
    osc->iphs = fabs(iphs); //iphs: initial phase
    osc->inc = 0;
    osc->lphs = ((int32_t)(osc->iphs * SP_FT_MAXLEN)) & SP_FT_PHMASK; //lphs: last phase (this is an incremental value, so it is used to create the current phase)
    osc->wtpos = 0.0;
    osc->nft = nft; // number of waveforms 4
    osc->nbl = nbl; // number of bandlimits 13

    uint32_t prev = (uint32_t)ft[0]->size;
    for(i = 0; i < nft * nbl; i++) {
        if(prev != ft[i]->size) {
            fprintf(stderr, "sp_oscmorph2d: size mismatch\n");
            return SP_NOT_OK;
        }
        prev = (uint32_t)ft[i]->size;
    }

    osc->fbl = fbls;
    float fblMin = fbls[0];
    for(i = 0; i < nbl - 1; i++) {
        if(fblMin > fbls[i + 1]) {
            fprintf(stderr, "sp_oscmorph2d: fbl must be in increasing order: %f, %f\n",fblMin,fbls[i + 1]);
            return SP_NOT_OK;
        }
        fblMin = fbls[i];
    }

    osc->enableBandlimit = 0;
    osc->bandlimitIndexOverride = -1;

    return SP_OK;
}

int sp_oscmorph2d_compute(sp_data *sp, sp_oscmorph2d *osc, SPFLOAT *in, SPFLOAT *out)
{
    sp_ftbl *ftp1;
    SPFLOAT amp, cps, fract, v1, v2;
    SPFLOAT *ft1, *ft2;
    int32_t phs, lobits, pos;
    SPFLOAT sicvt = osc->tbl[0]->sicvt; /* sicvt: this stands for Sampling Increment ConVert */
    const int enableBandlimit = osc->enableBandlimit;
    int bandlimitIndexOverride = osc->bandlimitIndexOverride;

    int32_t bandlimitIndex = 0;
    if (enableBandlimit > 0) {
        if (bandlimitIndexOverride < 0) {
            /* do not use override */
            for(int i = 1; i < osc->nbl; i++) {
                if(osc->freq <= osc->fbl[i]) {
                    bandlimitIndex = i;
                    break;
                }
            }
        } else {
            /* the override is the index */
            bandlimitIndex = floor(bandlimitIndexOverride);
            if (bandlimitIndex < 0)
                bandlimitIndex = 0;
        }
    } else {
        /* hard-code the "non-bandlimited" row of wavetables */
        bandlimitIndex = 0;
    }

    /* Use only the fractional part of the position or 1 */
    if (osc->wtpos > 1.0) {
        osc->wtpos -= (int)osc->wtpos;
    }
    
    const SPFLOAT findex = (bandlimitIndex * osc->nft) + osc->wtpos * (osc->nft - 1);
    const int index = floor(findex);
    const SPFLOAT wtfrac = findex - index;

    lobits = osc->tbl[index]->lobits;
    amp = osc->amp;
    cps = osc->freq;
    phs = osc->lphs;
    ftp1 = osc->tbl[index];
    ft1 = osc->tbl[index]->tbl;

    if(index >= (bandlimitIndex * osc->nft) + (osc->nft - 1)) {
        ft2 = ft1;
    } else {
        ft2 = osc->tbl[index + 1]->tbl;
    }
    
    osc->inc = (int32_t)lrintf(cps * sicvt);  

    fract = ((phs) & ftp1->lomask) * ftp1->lodiv;

    pos = phs >> lobits;

    v1 = (1 - wtfrac) * 
        *(ft1 + pos) + 
        wtfrac * 
        *(ft2 + pos);
    v2 = (1 - wtfrac) * 
        *(ft1 + ((pos + 1) % ftp1->size))+ 
        wtfrac * 
        *(ft2 + ((pos + 1) % ftp1->size));

    *out = (v1 + (v2 - v1) * fract) * amp;

    phs += osc->inc;
    phs &= SP_FT_PHMASK;

    osc->lphs = phs;
    return SP_OK;
}
