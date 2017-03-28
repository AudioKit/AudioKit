/*
 * Brown
 * 
 * Brownian noise algorithm based on implementation found here:
 * http://vellocet.com/dsp/noise/VRand.h
 * 
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_brown_create(sp_brown **p)
{
    *p = malloc(sizeof(sp_brown));
    return SP_OK;
}

int sp_brown_destroy(sp_brown **p)
{
    free(*p);
    return SP_OK;
}

int sp_brown_init(sp_data *sp, sp_brown *p)
{
    p->brown = 0.0;
    return SP_OK;
}

int sp_brown_compute(sp_data *sp, sp_brown *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT r;
    while(1) {
        r = (sp_rand(sp) % SP_RANDMAX) / (SPFLOAT)(SP_RANDMAX);
        r = ((r * 2) - 1) * 0.5;
        p->brown += r;
        if(p->brown < -8.0f || p->brown > 8.0f) {
            p->brown -= r;
        } else {
            break;
        }
    }

    *out = p->brown * 0.0625;
    return SP_OK;
}
