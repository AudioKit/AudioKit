#include <stdlib.h>
#include "soundpipe.h"
#include "vocwrapper.h"

int sp_vocwrapper_create(sp_vocwrapper **p)
{
    sp_vocwrapper *pp;
    *p = malloc(sizeof(sp_vocwrapper));
    pp = *p;
    sp_voc_create(&pp->voc);
    return SP_OK;
}

int sp_vocwrapper_destroy(sp_vocwrapper **p)
{
    sp_vocwrapper *pp = *p;
    sp_voc_destroy(&pp->voc);
    free(*p);
    return SP_OK;
}

int sp_vocwrapper_init(sp_data *sp, sp_vocwrapper *p)
{
    p->freq = 160;
    p->pos = 0.5;
    p->pos = 1;
    p->nasal = 0.0;
    p->tenseness = 0.6;
    sp_voc_init(sp, p->voc);
    return SP_OK;
}

int sp_vocwrapper_compute(sp_data *sp, sp_vocwrapper *p, SPFLOAT *in, SPFLOAT *out)
{
    sp_voc *voc;

    voc = p->voc;

    if(sp_voc_get_counter(voc) == 0) {
        sp_voc_set_velum(voc, 0.01 + 0.8 * p->nasal);
        sp_voc_set_tongue_shape(voc, 12 + 16.0*p->pos, p->diam*3.5);
    }
    sp_voc_set_frequency(voc, p->freq);
    sp_voc_set_tenseness(voc, p->tenseness);

    sp_voc_compute(sp, voc, out); 
    return SP_OK;
}
