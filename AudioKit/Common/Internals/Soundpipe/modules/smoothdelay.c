#include <stdlib.h>
#include "soundpipe.h"

#ifndef max
#define max(a, b) ((a > b) ? a : b)
#endif

#ifndef min
#define min(a, b) ((a < b) ? a : b)
#endif


int sp_smoothdelay_create(sp_smoothdelay **p)
{
    *p = malloc(sizeof(sp_smoothdelay));
    return SP_OK;
}

int sp_smoothdelay_destroy(sp_smoothdelay **p)
{
    sp_smoothdelay *pp = *p;
    sp_auxdata_free(&pp->buf1);
    sp_auxdata_free(&pp->buf2);
    free(*p);
    return SP_OK;
}

int sp_smoothdelay_init(sp_data *sp, sp_smoothdelay *p, 
        SPFLOAT maxdel, uint32_t interp)
{
    uint32_t n = (int32_t)(maxdel * sp->sr)+1;
    p->sr = sp->sr;
    p->del = maxdel * 0.5;
    p->pdel = -1;
    p->maxdel = maxdel;
    p->feedback = 0;
    p->maxbuf = n - 1;
    p->maxcount = interp;

    sp_auxdata_alloc(&p->buf1, n * sizeof(SPFLOAT));
    p->bufpos1 = 0;
    p->deltime1 = (uint32_t) (p->del * sp->sr);

    sp_auxdata_alloc(&p->buf2, n * sizeof(SPFLOAT));
    p->bufpos2 = 0;
    p->deltime2 = p->deltime1;

    p->counter = 0;
    p->curbuf = 0;
    return SP_OK;
}

static SPFLOAT delay_sig(SPFLOAT *buf, 
        uint32_t *bufpos, 
        uint32_t deltime, 
        SPFLOAT fdbk, 
        SPFLOAT in)
{
    SPFLOAT delay = buf[*bufpos];
    SPFLOAT sig = (delay * fdbk) + in;
    buf[*bufpos] = sig;
    *bufpos = (*bufpos + 1) % deltime;
    return delay;
}

int sp_smoothdelay_compute(sp_data *sp, sp_smoothdelay *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = 0;
    if(p->del != p->pdel && p->counter == 0) {
        uint32_t dels = min((uint32_t)(p->del * sp->sr), p->maxbuf);

        /* initial delay time sets time for both buffers */

        if(p->pdel < 0) {
            p->deltime1 = dels;
            p->deltime2 = dels;
        }

        p->pdel = p->del;

        if(dels == 0) dels = 1;

        if(p->curbuf == 0) {
            p->curbuf = 1;
            p->deltime2 = dels;
        } else {
            p->curbuf = 0;
            p->deltime1 = dels;
        }
        p->counter = p->maxcount;
    }



    SPFLOAT *buf1 = (SPFLOAT *)p->buf1.ptr; 
    SPFLOAT *buf2 = (SPFLOAT *)p->buf2.ptr; 
    SPFLOAT it = (SPFLOAT)p->counter / p->maxcount;
    if(p->counter != 0) p->counter--;
  
    SPFLOAT del1 = delay_sig(buf1, &p->bufpos1, 
            p->deltime1, p->feedback, *in);

    SPFLOAT del2 = delay_sig(buf2, &p->bufpos2, 
            p->deltime2, p->feedback, *in);

    if(p->curbuf == 0) {
        /* 1 to 2 */
        *out = (del1 * it) + (del2 * (1 - it));
    } else {
        /* 2 to 1 */
        *out = (del2 * it) + (del1 * (1 - it));
    }
    return SP_OK;
}
