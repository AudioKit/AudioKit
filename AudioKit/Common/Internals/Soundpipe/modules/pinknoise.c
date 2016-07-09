/*
 * Pinknoise
 *
 * This code has been extracted the pink noise synthesizer from Protrekkr
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): McCartney, Juan Antonio Arguelles
 * Location: release/distrib/replay/lib/replay.cpp
 *
 */
#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"


static uint32_t ctz[64] =
{
    6, 0, 1, 0, 2, 0, 1, 0,
    3, 0, 1, 0, 2, 0, 1, 0,
    4, 0, 1, 0, 2, 0, 1, 0,
    3, 0, 1, 0, 2, 0, 1, 0,
    5, 0, 1, 0, 2, 0, 1, 0,
    3, 0, 1, 0, 2, 0, 1, 0,
    4, 0, 1, 0, 2, 0, 1, 0,
    3, 0, 1, 0, 2, 0, 1, 0,
};

int sp_pinknoise_create(sp_pinknoise **p)
{
    *p = malloc(sizeof(sp_pinknoise));
    return SP_OK;
}

int sp_pinknoise_destroy(sp_pinknoise **p)
{
    free(*p);
    return SP_OK;
}

int sp_pinknoise_init(sp_data *sp, sp_pinknoise *p)
{
    int i;
    p->amp = 1.0;
    p->seed = sp_rand(sp);
    p->total = 0;
    p->counter = 0;
    for(i = 0; i < 7; i++) {
        p->dice[i] = 0;
    }
    return SP_OK;
}

int sp_pinknoise_compute(sp_data *sp, sp_pinknoise *p, SPFLOAT *in, SPFLOAT *out) 
{
    uint32_t k = ctz[p->counter & 63];
    p->prevrand = p->dice[k];
    p->seed = 1664525 * p->seed + 1013904223;
    p->newrand = p->seed >> 3;
    p->dice[k] = p->newrand;
    p->total += (p->newrand - p->prevrand);
    p->seed = 1103515245 * p->seed + 12345;
    p->newrand = p->seed >> 3;
    short tmp = (short) ((((p->total + p->newrand) * (1.0f / (3 << 29)) - 1) - .25f) * 16384.0f);
    *out = (SPFLOAT) tmp / sizeof(short) * p->amp;
    p->counter = (p->counter + 1) % 0xFFFFFFFF;
    return SP_OK;
}
