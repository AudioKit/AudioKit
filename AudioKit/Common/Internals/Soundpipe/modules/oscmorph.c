#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_oscmorph_create(sp_oscmorph **p)
{
    *p = malloc(sizeof(sp_oscmorph));
    return SP_OK;
}

int sp_oscmorph_destroy(sp_oscmorph **p)
{
    free(*p);
    return SP_OK;
}

int sp_oscmorph_init(sp_data *sp, sp_oscmorph *osc, sp_ftbl **ft, int nft, SPFLOAT iphs)
{
    int i;
    osc->freq = 440.0;
    osc->amp = 0.2;
    osc->tbl = ft;
    osc->iphs = fabs(iphs);
    osc->inc = 0;
    osc->lphs = ((int32_t)(osc->iphs * SP_FT_MAXLEN)) & SP_FT_PHMASK;
    osc->wtpos = 0.0;
    osc->nft = nft;
    uint32_t prev = (uint32_t)ft[0]->size;
    for(i = 0; i < nft; i++) {
        if(prev != ft[i]->size) {
            fprintf(stderr, "sp_oscmorph: size mismatch\n");
            return SP_NOT_OK;
        }
        prev = (uint32_t)ft[i]->size;
    }
    return SP_OK;
}

int sp_oscmorph_compute(sp_data *sp, sp_oscmorph *osc, SPFLOAT *in, SPFLOAT *out)
{
    sp_ftbl *ftp1;
    SPFLOAT amp, cps, fract, v1, v2;
    SPFLOAT *ftab1, *ftab2;
    SPFLOAT *ft1, *ft2;
    int32_t phs, lobits;
    SPFLOAT sicvt = osc->tbl[0]->sicvt;

    /* Use only the fractional part of the position or 1 */
    if (osc->wtpos > 1.0) {
        osc->wtpos -= (int)osc->wtpos;
    }
    SPFLOAT findex = osc->wtpos * (osc->nft - 1);
    int index = floor(findex);
    SPFLOAT wtfrac = findex - index;

    lobits = osc->tbl[0]->lobits;
    amp = osc->amp;
    cps = osc->freq;
    phs = osc->lphs;
    ftp1 = osc->tbl[index];
    ft1 = osc->tbl[index]->tbl;

    if(index >= osc->nft - 1) {
        ft2 = ft1;
    } else {
        ft2 = osc->tbl[index + 1]->tbl;
    }
    
    osc->inc = (int32_t)lrintf(cps * sicvt);

    fract = ((phs) & ftp1->lomask) * ftp1->lodiv;
    ftab1 = ft1 + (phs >> lobits);
    ftab2 = ft2 + (phs >> lobits);

    v1 = (1 - wtfrac) * ftab1[0] + wtfrac * ftab2[0];
    v2 = (1 - wtfrac) * ftab1[1] + wtfrac * ftab2[1];

    *out = (v1 + (v2 - v1) * fract) * amp;

    phs += osc->inc;
    phs &= SP_FT_PHMASK;

    osc->lphs = phs;
    return SP_OK;
}
