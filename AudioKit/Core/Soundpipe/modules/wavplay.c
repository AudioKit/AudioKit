//
//  wavplay.c
//  AudioKit
//
//  Created by Jeff Cooper on 4/23/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#include <stdlib.h>
#include "soundpipe.h"
#include "dr_wav.h"

#define WAVPLAY_BUFSIZE 1024

int sp_wavplay_create(sp_wavplay **p)
{
    *p = malloc(sizeof(sp_wavplay));
    return SP_OK;
}

int sp_wavplay_destroy(sp_wavplay **p)
{
    drwav_uninit(&(*p)->wav);
    free(*p);
    return SP_OK;
}

int sp_wavplay_init(sp_data *sp, sp_wavplay *p, const char *filename)
{
    p->count = 0;
    p->pos = 0;
    drwav_init_file(&p->wav, filename);
    return SP_OK;
}

int sp_wavplay_compute(sp_data *sp, sp_wavplay *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->pos > p->wav.totalSampleCount) {
        *out = 0;
        return SP_OK;
    }
    if(p->count == 0) {
        drwav_read_f32(&p->wav, WAVIN_BUFSIZE, p->buf);
    }

    *out = p->buf[p->count];
    p->count = (p->count + 1) % WAVIN_BUFSIZE;
    p->pos++;
    return SP_OK;
}

int sp_wavplay_resetToStart(sp_data *sp, sp_wavplay *p)
{
    drwav_seek_to_sample(&p->wav, 0);
    return SP_OK;
}

int sp_wavplay_seek(sp_data *sp, sp_wavplay *p, drwav_uint64 sample)
{
    drwav_seek_to_sample(&p->wav, sample);
    return SP_OK;
}
