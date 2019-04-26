//
//  wavin.c
//  AudioKit
//
//  Created by Jeff Cooper / Paul Batchelor on 6/20/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include <stdlib.h>
#include "soundpipe.h"
#include "dr_wav.h"
#include <math.h>

#define WAVIN_BUFSIZE 1024

int sp_wavin_create(sp_wavin **p)
{
    *p = malloc(sizeof(sp_wavin));
    return SP_OK;
}

int sp_wavin_destroy(sp_wavin **p)
{
    drwav_uninit(&(*p)->wav);
    free(*p);
    return SP_OK;
}

int sp_wavin_init(sp_wavin *p, const char *filename)
{
    p->count = 0;
    p->pos = 0;
    p->buffStart = 0;
    p->buffEnd = 0;
    drwav_init_file(&p->wav, filename);
    return SP_OK;
}

int sp_wavin_readBlock(sp_wavin *p, SPFLOAT *out, drwav_uint64 position)
{
    drwav_seek_to_sample(&p->wav, position);
    drwav_uint64 numberOfSampleRead = drwav_read_f32(&p->wav, WAVIN_BUFSIZE, p->buf);
    p->buffStart = position;
    p->buffEnd = position += numberOfSampleRead - 1;
    return SP_OK;
}

int sp_wavin_getSample(sp_wavin *p, SPFLOAT *out, float position)
{
    unsigned int integerPosition;
    float sample1, sample2;
    float fraction;
    int bufferPosition;

    integerPosition = floor(position);

    if(!(integerPosition >= p->buffStart && integerPosition < (p->buffEnd - 1))
       || (p->buffStart == p->buffEnd)) {
        sp_wavin_readBlock(p, out, integerPosition);
    }

    fraction = position - integerPosition;

    bufferPosition = (int)(integerPosition - p->buffStart);
    sample1 = p->buf[bufferPosition];
    sample2 = p->buf[bufferPosition + 1];

    *out = sample1 + (sample2 - sample1) * fraction;
    return SP_OK;
}

int sp_wavin_compute(sp_wavin *p, SPFLOAT *out)
{
    if(p->pos > p->wav.totalSampleCount) {
        *out = 0;
        return SP_OK;
    }
    if(p->count == 0) {
        sp_wavin_readBlock(p, out, p->pos);
    }

    *out = p->buf[p->count];
    p->count = (p->count + 1) % WAVIN_BUFSIZE;
    p->pos++;
    return SP_OK;
}

int sp_wavin_resetToStart(sp_wavin *p)
{
    drwav_seek_to_sample(&p->wav, 0);
    return SP_OK;
}

int sp_wavin_seek(sp_wavin *p, drwav_uint64 sample)
{
    drwav_seek_to_sample(&p->wav, sample);
    return SP_OK;
}
