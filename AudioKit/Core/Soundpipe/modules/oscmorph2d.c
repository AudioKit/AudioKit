#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#if 0
#define SP_FT_MAXLEN 0x1000000L
#define SP_FT_PHMASK 0x0FFFFFFL
typedef struct sp_ftbl{
    size_t size;
    uint32_t lobits;
    uint32_t lomask;
    SPFLOAT lodiv;
    SPFLOAT sicvt;
    SPFLOAT *tbl;
    char del;
}sp_ftbl;

#define tpd360  0.0174532925199433

/* initialize constants in ftable */
int sp_ftbl_init(sp_data *sp, sp_ftbl *ft, size_t size)
{
    ft->size = size;
    ft->sicvt = 1.0 * SP_FT_MAXLEN / sp->sr; // max length of table in samples divided by sample rate in samples
    ft->lobits = log2(SP_FT_MAXLEN / size); // slack to paul...assuming 2^x size for tables because return value is int
    ft->lomask = (1<<ft->lobits) - 1;
    ft->lodiv = 1.0 / (1<<ft->lobits);
    ft->del = 1;
    return SP_OK;
}

int sp_ftbl_create(sp_data *sp, sp_ftbl **ft, size_t size)
{
    *ft = malloc(sizeof(sp_ftbl));
    sp_ftbl *ftp = *ft;
    ftp->tbl = malloc(sizeof(SPFLOAT) * (size + 1));
    memset(ftp->tbl, 0, sizeof(SPFLOAT) * (size + 1));

    sp_ftbl_init(sp, ftp, size);
    return SP_OK;
}

int sp_ftbl_destroy(sp_ftbl **ft)
{
    sp_ftbl *ftp = *ft;
    if(ftp->del) free(ftp->tbl);
    free(*ft);
    return SP_OK;
}

typedef struct {
    SPFLOAT freq, amp, iphs;
    int32_t lphs;
    sp_ftbl **tbl;
    int inc;
    SPFLOAT wtpos;
    int nft; // number of waveforms
    int nbl; // number of bandlimited tables per waveform
} sp_oscmorph2d;
#endif

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

//    sp_oscmorph2d_init(kernel->spp(), oscmorph1,          kernel->ft_array, S1_NUM_WAVEFORMS, S1_NUM_BANDLIMITED_FTABLES, 0);
int sp_oscmorph2d_init(sp_data *sp,   sp_oscmorph2d *osc,     sp_ftbl **ft,          int nft,                    int nbl, SPFLOAT iphs)
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
    osc->nbl = nbl;
    uint32_t prev = (uint32_t)ft[0]->size;
    for(i = 0; i < nft; i++) {
        if(prev != ft[i]->size) {
            fprintf(stderr, "sp_oscmorph2: size mismatch\n");
            return SP_NOT_OK;
        }
        prev = (uint32_t)ft[i]->size;
    }
    return SP_OK;
}

int sp_oscmorph2d_compute(sp_data *sp, sp_oscmorph2d *osc, SPFLOAT *in, SPFLOAT *out)
{
    sp_ftbl *ftp1;
    SPFLOAT amp, cps, fract, v1, v2;
    SPFLOAT *ft1, *ft2;
    int32_t phs, lobits, pos;
    SPFLOAT sicvt = osc->tbl[0]->sicvt;

    /* Use only the fractional part of the position or 1 */ /* if? why not while? */
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
