#include <stdlib.h>
#include <math.h>
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

int sp_wavin_init(sp_data *sp, sp_wavin *p, const char *filename)
{
    p->count = 0;
    p->pos = 0;
    p->buf_start = 0;
    p->buf_end = 0;
    drwav_init_file(&p->wav, filename);
    return SP_OK;
}

static void read_block(sp_data *sp, sp_wavin *p, unsigned long position)
{
    sp_wavin_seek(sp, p, position);
    unsigned long samps_read = (unsigned long)drwav_read_f32(&p->wav, WAVIN_BUFSIZE, p->buf);
    p->buf_start = position;
    p->buf_end = position + samps_read - 1;
}

int sp_wavin_compute(sp_data *sp, sp_wavin *p, SPFLOAT *in, SPFLOAT *out)
{
    if(p->pos > p->wav.totalSampleCount) {
        *out = 0;
        return SP_OK;
    }
    if(p->count == 0) {
        read_block(sp, p, p->pos);
    }

    *out = p->buf[p->count];
    p->count = (p->count + 1) % WAVIN_BUFSIZE;
    p->pos++;
    return SP_OK;
}

int sp_wavin_get_sample(sp_data *sp, sp_wavin *p, SPFLOAT *out, SPFLOAT pos)
{
    unsigned long ipos;
    float samp1, samp2;
    float frac;
    int buf_pos;

    ipos = floor(pos);

    if(!(ipos >= p->buf_start && ipos < (p->buf_end - 1))
       || (p->buf_start == p->buf_end)) {
        read_block(sp, p, ipos);
    }

    frac = pos - ipos;

    buf_pos = (int)(ipos - p->buf_start);
    samp1 = p->buf[buf_pos];
    samp2 = p->buf[buf_pos + 1];

    *out = samp1 + (samp2 - samp1) * frac;
    return SP_OK;
}


int sp_wavin_reset_to_start(sp_data *sp, sp_wavin *p)
{
    sp_wavin_seek(sp, p, 0);
    return SP_OK;
}

int sp_wavin_seek(sp_data *sp, sp_wavin *p, unsigned long sample)
{
    drwav_seek_to_sample(&p->wav, sample);
    return SP_OK;
}
