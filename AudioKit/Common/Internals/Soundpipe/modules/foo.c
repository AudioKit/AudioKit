/*
 * Foo
 * 
 * This is a dummy module. It doesn't do much.
 * Feel free to use this as a boilerplate template.
 * 
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_foo_create(sp_foo **p)
{
    *p = malloc(sizeof(sp_foo));
    return SP_OK;
}

int sp_foo_destroy(sp_foo **p)
{
    free(*p);
    return SP_OK;
}

int sp_foo_init(sp_data *sp, sp_foo *p)
{
    /* Initalize variables here. */
    p->bar = 123;
    return SP_OK;
}

int sp_foo_compute(sp_data *sp, sp_foo *p, SPFLOAT *in, SPFLOAT *out)
{
    /* Send the signal's input to the output */
    *out = *in;
    return SP_OK;
}
