#include <stdlib.h>
#include "soundpipe.h"

int sp_tenv_create(sp_tenv **p)
{
    *p = malloc(sizeof(sp_tenv));
    sp_tenv *pp = *p;
    sp_tevent_create(&pp->te);
    return SP_OK;
}

int sp_tenv_destroy(sp_tenv **p)
{
    sp_tenv *pp = *p;
    sp_tevent_destroy(&pp->te);
    free(*p);
    return SP_OK;
}

static void sp_tenv_reinit(void *ud)
{
    sp_tenv *env = ud;
    env->pos = 0;
    env->atk_end = env->sr * env->atk;
    env->rel_start = env->sr * (env->atk + env->hold);
    env->atk_slp = 1.0 / env->atk_end;
    env->rel_slp = -1.0 / (env->sr * env->rel);
    env->totaldur = env->sr * (env->atk + env->hold + env->rel);
}

static void sp_tenv_comp(void *ud, SPFLOAT *out)
{
    sp_tenv *env = ud;
    SPFLOAT sig = 0;
    uint32_t pos = env->pos;
    *out = 0.0;
    if(pos < env->atk_end){
        sig = env->last + env->atk_slp;
    }else if (pos < env->rel_start){
        sig = 1.0;
    }else if (pos < env->totaldur){
        sig = env->last + env->rel_slp;
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

int sp_tenv_init(sp_data *sp, sp_tenv *p)
{
    p->pos = 0;
    p->last = 0;
    p->atk = 0.1;
    p->hold = 0.3;
    p->rel = 0.2;
    p->sigmode = 0;
    p->input = 0;

    p->sr = sp->sr;
    p->atk_end = p->sr * p->atk;
    p->rel_start = p->sr * (p->atk + p->hold);
    p->atk_slp = 1.0 / p->atk_end;
    p->rel_slp = -1.0 / (p->sr * p->rel);
    p->totaldur = p->sr * (p->atk + p->hold + p->rel);
    sp_tevent_init(sp, p->te, sp_tenv_reinit, sp_tenv_comp, p);
    return SP_OK;
}

int sp_tenv_compute(sp_data *sp, sp_tenv *p, SPFLOAT *in, SPFLOAT *out)
{
    sp_tevent_compute(sp, p->te, in, out);
    return SP_OK;
}
