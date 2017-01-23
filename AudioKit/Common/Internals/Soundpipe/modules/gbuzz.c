/*
 * GBuzz
 * 
 * This code has been extracted from the Csound opcode "gbuzz".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Gabriel Maldonado
 * Year: 1991
 * Location: ugens/ugens4.c
 *
 */
#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"

/* Binary positive power function */
static SPFLOAT intpow1(SPFLOAT x, int32_t n)   
{
    SPFLOAT ans = 1.0;
    while (n!=0) {
      if (n&1) ans = ans * x;
      n >>= 1;
      x = x*x;
    }
    return ans;
}


int sp_gbuzz_create(sp_gbuzz **p)
{
    *p = malloc(sizeof(sp_gbuzz));
    return SP_OK;
}

int sp_gbuzz_destroy(sp_gbuzz **p)
{
    free(*p);
    return SP_OK;
}

int sp_gbuzz_init(sp_data *sp, sp_gbuzz *p, sp_ftbl *ft, SPFLOAT iphs)
{
    p->freq = 440;
    p->amp = 0.4;
    p->nharm = 4;
    p->lharm = 1;
    p->mul = 0.1;
    p->ft = ft;
    p->iphs = iphs; 
    
    if (p->iphs >= 0) {
        p->lphs = (int32_t)(p->iphs * SP_FT_MAXLEN);
        p->prvr = 0.0;
    }
    p->last = 1.0;
    return SP_OK;
}

int sp_gbuzz_compute(sp_data *sp, sp_gbuzz *p, SPFLOAT *in, SPFLOAT *out)
{
    sp_ftbl *ftp;
    SPFLOAT *ftbl;
    int32_t phs, inc, lobits, lenmask, k, km1, kpn, kpnm1;
    SPFLOAT r, absr, num, denom, scal, last = p->last;
    int32_t nn, lphs = p->lphs;
    
    ftp = p->ft;
    ftbl = ftp->tbl;
    lobits = ftp->lobits;
    lenmask = (int32_t) ftp->size - 1;
    k = (int32_t)p->lharm;
    
    if ((nn = (int32_t)p->nharm)<0) nn = -nn;
    
    if (nn == 0) {
        nn = 1;
    }
    km1 = k - 1;
    kpn = k + nn;
    kpnm1 = kpn - 1;
    
    if ((r = p->mul) != p->prvr || nn != p->prvn) {
        p->twor = r + r;
        p->rsqp1 = r * r + 1.0;
        p->rtn = intpow1(r, nn);
        p->rtnp1 = p->rtn * r;
        
        if ((absr = fabs(r)) > 0.999 && absr < 1.001) {
            p->rsumr = 1.0 / nn;
        } else {
            p->rsumr = (1.0 - absr) / (1.0 - fabs(p->rtn));
        }
        
        p->prvr = r;
        p->prvn = (int16_t)nn;
    }
    
    scal =  p->amp * p->rsumr;
    inc = (int32_t)(p->freq * ftp->sicvt);
    phs = lphs >>lobits;
    denom = p->rsqp1 - p->twor * ftbl[phs];
    num = ftbl[phs * k & lenmask]
        - r * ftbl[phs * km1 & lenmask]
        - p->rtn * ftbl[phs * kpn & lenmask]
        + p->rtnp1 * ftbl[phs * kpnm1 & lenmask];
    
    if (denom > 0.0002 || denom < -0.0002) {
        *out = last = num / denom * scal;
    } else if (last<0) {
        *out = last = - *out;
    } else {
        *out = last = *out;
    }
    
    lphs += inc;
    lphs &= SP_FT_PHMASK;
    p->last = last;
    p->lphs = lphs;
    return SP_OK;
}
