#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "soundpipe.h"

int sp_create(sp_data **spp)
{
    *spp = (sp_data *) malloc(sizeof(sp_data));
    sp_data *sp = *spp;
    sprintf(sp->filename, "test.wav");
    sp->nchan = 1;
    SPFLOAT *out = malloc(sizeof(SPFLOAT) * sp->nchan);
    *out = 0;
    sp->out = out;
    sp->sr = 44100;
    sp->len = 5 * sp->sr;
    sp->pos = 0;
    sp->k = 1;
    sp->rand = 0;
    return 0;
}

int sp_createn(sp_data **spp, int nchan)
{
    *spp = (sp_data *) malloc(sizeof(sp_data));
    sp_data *sp = *spp;
    sprintf(sp->filename, "test.wav");
    sp->nchan = nchan;
    SPFLOAT *out = malloc(sizeof(SPFLOAT) * sp->nchan);
    *out = 0;
    sp->out = out;
    sp->sr = 44100;
    sp->len = 5 * sp->sr;
    sp->pos = 0;
    sp->k = 1;
    sp->rand = 0;
    return 0;
}

int sp_destroy(sp_data **spp)
{
    sp_data *sp = *spp;
    free(sp->out);
    free(*spp);
    return 0;
}

#ifndef NO_LIBSNDFILE

//int sp_process(sp_data *sp, void *ud, void (*callback)(sp_data *, void *))
//{
//    SNDFILE *sf[sp->nchan];
//    char tmp[140];
//    SF_INFO info;
//    SPFLOAT buf[sp->nchan][SP_BUFSIZE];
//    info.samplerate = sp->sr;
//    info.channels = 1;
//    info.format = SF_FORMAT_WAV | SF_FORMAT_PCM_24;
//    int numsamps, i, chan;
//    if(sp->nchan == 1) {
//        sf[0] = sf_open(sp->filename, SFM_WRITE, &info);
//    } else {
//        for(chan = 0; chan < sp->nchan; chan++) {
//            sprintf(tmp, "%02d_%s", chan, sp->filename);
//            sf[chan] = sf_open(tmp, SFM_WRITE, &info);
//        }
//    }
//
//    while(sp->len > 0){
//        if(sp->len < SP_BUFSIZE) {
//            numsamps = sp->len;
//        }else{
//            numsamps = SP_BUFSIZE;
//        }
//        for(i = 0; i < numsamps; i++){
//            callback(sp, ud);
//            for(chan = 0; chan < sp->nchan; chan++) {
//                buf[chan][i] = sp->out[chan];
//            }
//            sp->pos++;
//        }
//        for(chan = 0; chan < sp->nchan; chan++) {
//            sf_write_float(sf[chan], buf[chan], numsamps);
//        }
//        sp->len -= numsamps;
//    }
//    for(i = 0; i < sp->nchan; i++) {
//        sf_close(sf[i]);
//    }
//    return 0;
//}

#endif

int sp_process_raw(sp_data *sp, void *ud, void (*callback)(sp_data *, void *))
{
    int chan;
    if(sp->len == 0) {
        while(1) {
            callback(sp, ud);
            for (chan = 0; chan < sp->nchan; chan++) {
                fwrite(&sp->out[chan], sizeof(SPFLOAT), 1, stdout);
            }
            sp->len--;
        }
    } else {
        while(sp->len > 0) {
            callback(sp, ud);
            for (chan = 0; chan < sp->nchan; chan++) {
                fwrite(&sp->out[chan], sizeof(SPFLOAT), 1, stdout);
            }
            sp->len--;
            sp->pos++;
        }
    }
    return SP_OK;
}
int sp_auxdata_alloc(sp_auxdata *aux, size_t size)
{
    aux->ptr = malloc(size);
    aux->size = size;
    memset(aux->ptr, 0, size);
    return SP_OK;
}

int sp_auxdata_free(sp_auxdata *aux)
{
    free(aux->ptr);
    return SP_OK;
}

int sp_auxdata_getbuf(sp_auxdata *aux, uint32_t pos, SPFLOAT *out)
{
    if(pos * sizeof(SPFLOAT) > aux->size){
        fprintf(stderr, "Error: Buffer overflow!\n");
        *out = 0;
        return SP_NOT_OK;
    }else{
        SPFLOAT *tmp = aux->ptr;
        *out = tmp[pos];
    }
    return SP_OK;

}

int sp_auxdata_setbuf(sp_auxdata *aux, uint32_t pos, SPFLOAT *in)
{
    if((pos * sizeof(SPFLOAT)) > aux->size){
        fprintf(stderr, "Error: Buffer overflow!\n");
        return SP_NOT_OK;
    }else{
        SPFLOAT *tmp = aux->ptr;
        SPFLOAT n = *in;
        tmp[pos] = n;
    }
    return SP_OK;
}

SPFLOAT sp_midi2cps(SPFLOAT nn)
{
    return pow(2, (nn - 69.0) / 12.0) * 440.0;
}

int sp_set(sp_param *p, SPFLOAT val) {
    p->state = 1;
    p->val = val;
    return SP_OK;
}

int sp_out(sp_data *sp, uint32_t chan, SPFLOAT val)
{
    if(chan > sp->nchan - 1) {
        fprintf(stderr, "sp_out: Invalid channel\n");
        return SP_NOT_OK;
    }
    sp->out[chan] = val;
    return SP_OK;
}

uint32_t sp_rand(sp_data *sp)
{
    uint32_t val = (1103515245 * sp->rand + 12345) % SP_RANDMAX;
    sp->rand = val;
    return val;
}

void sp_srand(sp_data *sp, uint32_t val)
{
    sp->rand = val;
}
