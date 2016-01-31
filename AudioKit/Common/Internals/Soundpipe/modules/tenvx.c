#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

int sp_tenvx_create(sp_tenvx **p)
{
    *p = malloc(sizeof(sp_tenvx));
    sp_tenvx *pp = *p;
    sp_tevent_create(&pp->te);
    return SP_OK;
}

int sp_tenvx_destroy(sp_tenvx **p)
{
    sp_tenvx *pp = *p;
    sp_tevent_destroy(&pp->te);
    free(*p);
    return SP_OK;
}

static void sp_tenvx_comp(void *ud, SPFLOAT *out)
{
    sp_tenvx *env = ud;
    SPFLOAT sig = 0;
    uint32_t pos = env->pos;
    *out = 0.0;
    if(pos < env->atk_end){
        sig = env->last * env->atk_slp;
    }else if (pos < env->rel_start){
        sig = 1.0;
    }else if (pos < env->totaldur){
        sig = env->last * env->rel_slp;
    }else{
        sig = 0.0;
    }
    sig = (sig > 1.0) ? 1.0 : sig;
    sig = (sig < 0.0) ? 0.0 : sig;

    /* Internal input signal mode */
    if(env->sigmode) {
        *out = env->input * sig;
    } else {
        *out = sig;
    }


    env->pos++;
    env->last = sig;
}

static void sp_tenvx_reinit(void *ud)
{
    sp_tenvx *env = ud;
    if(env->atk * env->rel == 0) {
        fprintf(stderr, "Warning, attack and release times cannot be zero\n");
    }
    env->pos = 0;
    env->atk_end = env->sr * env->atk;
    env->rel_start = env->sr * (env->atk + env->hold);
    env->atk_slp = 1.0 / env->atk_end;
    env->rel_slp = -1.0 / (env->sr * env->rel);
    env->totaldur = env->sr * (env->atk + env->hold + env->rel);
}

int sp_tenvx_init(sp_data *sp, sp_tenvx *p)
{
    p->pos = 0;
    p->last = 0;
    p->atk = 0.1;
    p->hold = 0.3;
    p->rel = 0.2;
    p->sigmode = 0;
    p->input = 0;

    SPFLOAT onedsr = 1.0 / sp->sr;

    p->sr = sp->sr;
    p->atk_end = p->sr * p->atk;
    p->rel_start = p->sr * (p->atk + p->hold);
    p->atk_slp = pow((SPFLOAT)(1.0/0.000001), onedsr / p->atk);
    p->rel_slp = pow((SPFLOAT)(0.000001/1.0), onedsr / p->rel);
    p->totaldur = p->sr * (p->atk + p->hold + p->rel);
    sp_tevent_init(sp, p->te, sp_tenvx_reinit, sp_tenvx_comp, p);
    return SP_OK;
}


int sp_tenvx_compute(sp_data *sp, sp_tenvx *p, SPFLOAT *in, SPFLOAT *out)
{
    sp_tevent_compute(sp, p->te, in, out);
    return SP_OK;
}
