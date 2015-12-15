/*
 * Foo
 * 
 * This is a dummy module. It doesn't do much.
 * Feel free to use this as a boilerplate template.
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_delay1_create(sp_delay1 **p)
{
    *p = malloc(sizeof(sp_delay1));
    return SP_OK;
}

int sp_delay1_destroy(sp_delay1 **p)
{
    free(*p);
    return SP_OK;
}

int sp_delay1_init(sp_data *sp, sp_delay1 *p)
{
    /* Initalize variables here. */
    p->samp = 0;
    return SP_OK;
}

int sp_delay1_compute(sp_data *sp, sp_delay1 *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = p->samp;
    p->samp = *in;
    return SP_OK;
}
