/*
 * Waveset
 *
 * This code has been extracted from the Csound opcode "waveset".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): Trevor Wishart, John ffitch
 * Year: 2001
 * Location: Opcodes/pitch.c
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_waveset_create(sp_waveset **p)
{
    *p = malloc(sizeof(sp_waveset));
    return SP_OK;
}

int sp_waveset_destroy(sp_waveset **p)
{
    sp_waveset *pp = *p;
    sp_auxdata_free(&pp->auxch);
    free(*p);
    return SP_OK;
}

int sp_waveset_init(sp_data *sp, sp_waveset *p, SPFLOAT ilen)
{
    p->length = 1 + (sp->sr * ilen);

    sp_auxdata_alloc(&p->auxch, p->length * sizeof(SPFLOAT));
    p->cnt = 1;
    p->start = 0;
    p->current = 0;
    p->end = 0;
    p->direction = 1;
    p->lastsamp = 1.0;
    p->noinsert = 0;
    return SP_OK;
}

int sp_waveset_compute(sp_data *sp, sp_waveset *p, SPFLOAT *in, SPFLOAT *out)
{
    int index = p->end;
    SPFLOAT *insert = (SPFLOAT*)(p->auxch.ptr) + index;

    if (p->noinsert) goto output;
    *insert++ = *in;
    if (++index ==  p->start) {
        p->noinsert = 1;
    }
    if (index==p->length) {  
        index = 0;
        insert = (SPFLOAT*)(p->auxch.ptr);
    }

    output:

    p->end = index;
    index = p->current;
    insert = (SPFLOAT*)(p->auxch.ptr) + index;
    SPFLOAT samp = *insert++;
    index++;

    if (index==p->length) {
        index = 0;
        insert = (SPFLOAT*)(p->auxch.ptr);
        p->noinsert = 0;
    }

    if (samp != 0.0 && p->lastsamp*samp < 0.0) {
        if (p->direction == 1) {
            p->direction = -1;
        } else {
            p->direction = 1;
            if (++p->cnt > p->rep) {
                p->cnt = 1;
                p->start = index;
                p->noinsert = 0;
            } else { index = p->start;
                insert = (SPFLOAT*)(p->auxch.ptr) + index;
            }
        }
    }

    if (samp != 0.0) p->lastsamp = samp;
    *out = samp;
    p->current = index;

    return SP_OK;
}
