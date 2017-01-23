/*
 * TADSR
 * 
 * This module uses modified code from Perry Cook's ADSR STK module.
 * 
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

enum{ ATTACK, DECAY, SUSTAIN, RELEASE, CLEAR, KEY_ON, KEY_OFF };

static void make_Envelope(sp_tadsr *e)
{
    e->target = 0.0;
    e->value = 0.0;
    e->rate = 0.001;
    e->state = 1;
}

static void make_ADSR(sp_tadsr *a)
{
    make_Envelope(a);
    a->target = 0.0;
    a->value = 0.0;
    a->attackRate = 0.001;
    a->decayRate = 0.001;
    a->sustainLevel = 0.0;
    a->releaseRate = 0.01;
    a->state = CLEAR;
}

static void ADSR_keyOn(sp_tadsr *a)
{
    a->target = 1.0;
    a->rate = a->attackRate;
    a->state = ATTACK;
}

static void ADSR_keyOff(sp_tadsr *a)
{
    a->target = 0.0;
    a->rate = a->releaseRate;
    a->state = RELEASE;
}

static void ADSR_setSustainLevel(sp_data *sp, sp_tadsr *a, SPFLOAT aLevel)
{
   a->sustainLevel = aLevel;
}

static void ADSR_setAttackTime(sp_data *sp, sp_tadsr *a, SPFLOAT aTime)
{
    a->attackRate = 1.0 / (aTime * sp->sr);
}

static void ADSR_setDecayTime(sp_data *sp, sp_tadsr *a, SPFLOAT aTime)
{
    a->decayRate = 1.0 / (aTime * sp->sr);
}

static void ADSR_setReleaseTime(sp_data *sp, sp_tadsr *a, SPFLOAT aTime)
{
    a->releaseRate = 1.0 / (aTime * sp->sr);
}

static void ADSR_setAllTimes(sp_data *sp, sp_tadsr *a, SPFLOAT attTime, SPFLOAT decTime,
                      SPFLOAT susLevel, SPFLOAT relTime)
{
    ADSR_setAttackTime(sp, a, attTime);
    ADSR_setDecayTime(sp, a, decTime);
    ADSR_setSustainLevel(sp, a, susLevel);
    ADSR_setReleaseTime(sp, a, relTime);
}

static SPFLOAT ADSR_tick(sp_tadsr *a)
{
    SPFLOAT out = 0;
    if (a->state == ATTACK) {
        a->value += a->rate;
        if (a->value >= a->target) {
            a->value = a->target;
            a->rate = a->decayRate;
            a->target = a->sustainLevel;
            a->state = DECAY;
        }
        out = a->value;
    } else if (a->state == DECAY) {
        a->value -= a->decayRate;
        out = a->value;
        if (a->value <= a->sustainLevel) {
            a->value = a->sustainLevel;
            out = a->sustainLevel;
            a->rate = 0.0;
            a->state = SUSTAIN;
        }
    } else if (a->state == RELEASE)  {
        a->value -= a->releaseRate;
        if (a->value <= 0.0) {
            a->value = 0.0;
            a->state = CLEAR;
        }
        out = a->value;
    } else if (a->state == SUSTAIN)  {
        out = a->sustainLevel;
    }
    return out;
}

int sp_tadsr_create(sp_tadsr **p)
{
    *p = malloc(sizeof(sp_tadsr));
    return SP_OK;
}

int sp_tadsr_destroy(sp_tadsr **p)
{
    free(*p);
    return SP_OK;
}

int sp_tadsr_init(sp_data *sp, sp_tadsr *p)
{
    make_ADSR(p);
    p->atk = 0.5;
    p->dec = 0.5;
    p->sus = 0.0;
    p->rel = 0.5;
    p->mode = KEY_OFF;
    return SP_OK;
}

int sp_tadsr_compute(sp_data *sp, sp_tadsr *p, SPFLOAT *trig, SPFLOAT *out)
{
    if(*trig != 0) {

        if(*trig == 2) {
            ADSR_keyOff(p);
            p->mode = KEY_OFF;
        }else if(p->mode == KEY_OFF) {
            ADSR_setAllTimes(sp, p, p->atk, p->dec, p->sus, p->rel);
            ADSR_keyOn(p);
            p->mode = KEY_ON;
        } else {
            ADSR_keyOff(p);
            p->mode = KEY_OFF;
        }
    }
    *out = ADSR_tick(p);
    return SP_OK;
}
