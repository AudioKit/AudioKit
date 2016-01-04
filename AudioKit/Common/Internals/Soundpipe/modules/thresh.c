/*
 * Foo
 * 
 * This is a dummy module. It doesn't do much.
 * Feel free to use this as a boilerplate template.
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_thresh_create(sp_thresh **p)
{
    *p = malloc(sizeof(sp_thresh));
    return SP_OK;
}

int sp_thresh_destroy(sp_thresh **p)
{
    free(*p);
    return SP_OK;
}

int sp_thresh_init(sp_data *sp, sp_thresh *p)
{
    /* Initalize variables here. */
    p->init = 1;
    p->mode = 0;
    p->prev = 0;
    p->thresh = 0;
    return SP_OK;
}

int sp_thresh_compute(sp_data *sp, sp_thresh *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->init) {
        *out = 0;
        p->prev = *in;
        p->init = 0;
        return SP_OK;
    }

    switch(p->mode) {
        /* input signal goes above threshold */
        case 0:
            *out = (*in > p->thresh && p->prev <= p->thresh);
            break;

        /* input signal goes below threshold */
        case 1:
            *out = (*in < p->thresh && p->prev >= p->thresh);
            break;

        /* input signal goes below or above threshold */
        case 2:
            *out = (*in < p->thresh && p->prev >= p->thresh) ||
                (*in > p->thresh && p->prev <= p->thresh);
            break;

        default:
            return SP_NOT_OK;
    }

    p->prev = *in;
    
    return SP_OK;
}
