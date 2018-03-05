#include <stdlib.h>
#include "soundpipe.h"

int sp_switch_create(sp_switch **p)
{
    *p = malloc(sizeof(sp_switch));
    return SP_OK;
}

int sp_switch_destroy(sp_switch **p)
{
    free(*p);
    return SP_OK;
}

int sp_switch_init(sp_data *sp, sp_switch *p)
{
    p->mode = 0;
    return SP_OK;
}

int sp_switch_compute(sp_data *sp, sp_switch *p, SPFLOAT *trig,
    SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out)
{
    if (*trig) {
        p->mode = p->mode == 0 ? 1 : 0;
    }

    if(p->mode == 0) {
        *out = *in1;
    } else {
        *out = *in2;
    }

    return SP_OK;
}
