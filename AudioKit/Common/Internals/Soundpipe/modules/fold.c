/*
 * Fold
 *
 * This code has been extracted from the Csound opcode "fold".
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author(s): John FFitch, Gabriel Maldonado
 * Year: 1998
 * Location: OOps/ugens2.c
 *
 */

#include <stdlib.h>
#include "soundpipe.h"

int sp_fold_create(sp_fold **p)
{
    *p = malloc(sizeof(sp_fold));
    return SP_OK;
}

int sp_fold_destroy(sp_fold **p)
{
    free(*p);
    return SP_OK;
}

int sp_fold_init(sp_data *sp, sp_fold *p)
{
    p->incr = 1000;
    p->sample_index = 0;
    p->index = 0.0;
    p->value = 0.0; 
    return SP_OK;
}

int sp_fold_compute(sp_data *sp, sp_fold *p, SPFLOAT *in, SPFLOAT *out)
{
    SPFLOAT index = p->index;
    int32_t sample_index = p->sample_index;
    SPFLOAT value = p->value;
    if (index < (SPFLOAT)sample_index) {
        index += p->incr;
        *out = value = *in;
    } else {
        *out = value;
    }
    sample_index++;
    p->index = index;
    p->sample_index = sample_index;
    p->value = value;
    return SP_OK;
}
