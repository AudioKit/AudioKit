/*
 * TADSR
 * 
 * This module uses modified code from Perry Cook's ADSR STK module.
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

#define RATE_NORM (22050.0 / sp->sr)

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
    a->sustainLevel = 0.5;
    a->releaseRate = 0.01;
    a->state = ATTACK;
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
/*
static void ADSR_setAttackRate(sp_data *sp, sp_tadsr *a, SPFLOAT aRate)
{
    a->attackRate = aRate;
    a->attackRate *= RATE_NORM;
}

static void ADSR_setDecayRate(sp_data *sp, sp_tadsr *a, SPFLOAT aRate)
{
    a->decayRate = aRate;
    a->decayRate *= RATE_NORM;
}
*/
static void ADSR_setSustainLevel(sp_data *sp, sp_tadsr *a, SPFLOAT aLevel)
{
   a->sustainLevel = aLevel;
}
/*
static void ADSR_setReleaseRate(sp_data *sp, sp_tadsr *a, SPFLOAT aRate)
{
    a->releaseRate = aRate;
    a->releaseRate *= RATE_NORM;
}
*/
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
/*
static void ADSR_setAll(sp_data *sp, sp_tadsr *a, SPFLOAT attRate, SPFLOAT decRate,
    SPFLOAT susLevel, SPFLOAT relRate)
{
    ADSR_setAttackRate(sp, a, attRate);
    ADSR_setDecayRate(sp, a, decRate);
    ADSR_setSustainLevel(sp, a, susLevel);
    ADSR_setReleaseRate(sp, a, relRate);
}

static void ADSR_setTarget(sp_data *sp, sp_tadsr *a, SPFLOAT aTarget)
{
    a->target = aTarget;
    if (a->value <a-> target) {
      a->state = ATTACK;
      ADSR_setSustainLevel(sp, a, a->target);
      a->rate = a->attackRate;
    }
    if (a->value > a->target) {
      ADSR_setSustainLevel(sp, a, a->target);
      a->state = DECAY;
      a->rate = a->decayRate;
    }
}
*/
static SPFLOAT ADSR_tick(sp_tadsr *a)
{
    if (a->state==ATTACK) {
      a->value += a->rate;
      if (a->value >= a->target) {
        a->value = a->target;
        a->rate = a->decayRate;
        a->target = a->sustainLevel;
        a->state = DECAY;
      }
    }
    else if (a->state==DECAY) {
      a->value -= a->decayRate;
      if (a->value <= a->sustainLevel) {
        a->value = a->sustainLevel;
        a->rate = 0.0;
        a->state = SUSTAIN;
      }
    }
    else if (a->state==RELEASE)  {
      a->value -= a->releaseRate;
      if (a->value <= 0.0) {
        a->value = 0.0;
        a->state = CLEAR;
      }
    }
    return a->value;
}
/*
static void ADSR_setValue(sp_data *sp, sp_tadsr *a, SPFLOAT aValue)
{
    a->state = SUSTAIN;
    a->target = aValue;
    a->value = aValue;
    ADSR_setSustainLevel(sp, a, aValue);
    a->rate = 0.0;
}
*/
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
    p->sus = 0.5;
    p->rel = 0.5;
    p->mode = KEY_OFF;
    return SP_OK;
}

int sp_tadsr_compute(sp_data *sp, sp_tadsr *p, SPFLOAT *trig, SPFLOAT *out)
{
    if(*trig != 0) {

        if(p->mode == KEY_OFF) {
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
