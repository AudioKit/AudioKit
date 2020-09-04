#include <stdlib.h>
#include "soundpipe.h"
#include "dr_wav.h"

#define WAVOUT_BUFSIZE 1024

struct sp_wavout {
    drwav *wav;
    drwav_data_format format;
    SPFLOAT buf[WAVOUT_BUFSIZE];
    int count;
};

int sp_wavout_create(sp_wavout **p)
{
    *p = malloc(sizeof(sp_wavout));
    return SP_OK;
}

int sp_wavout_destroy(sp_wavout **p)
{
    /* write any remaining samples */
    if((*p)->count != 0) {
        drwav_write((*p)->wav, (*p)->count, (*p)->buf);
    }
    drwav_close((*p)->wav);
    free(*p);
    return SP_OK;
}

int sp_wavout_init(sp_data *sp, sp_wavout *p, const char *filename)
{
    p->count = 0;
    p->format.container = drwav_container_riff;
    p->format.format = DR_WAVE_FORMAT_IEEE_FLOAT;
    p->format.channels = 1;
    p->format.sampleRate = sp->sr;
    p->format.bitsPerSample = 32;
    p->wav = drwav_open_file_write(filename, &p->format);
    return SP_OK;
}

int sp_wavout_compute(sp_data *sp, sp_wavout *p, SPFLOAT *in, SPFLOAT *out)
{
    *out = *in;
    if(p->count == WAVOUT_BUFSIZE) {
        drwav_write(p->wav, WAVOUT_BUFSIZE, p->buf);
        p->count = 0;
    }
    p->buf[p->count] = *in;
    p->count++;
    return SP_OK;
}
