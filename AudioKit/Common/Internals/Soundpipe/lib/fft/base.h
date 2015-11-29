#include <stdint.h>
#include <stdio.h>

#ifndef NO_LIBSNDFILE
#include "sndfile.h"
#endif 

#define SP_BUFSIZE 4096
#ifndef SPFLOAT
#define SPFLOAT float
#endif 
#define SP_OK 1
#define SP_NOT_OK 0

#define SP_RANDMAX 2147483648

#ifndef SOUNDPIPE_H
#define SOUNDPIPE_H
#endif

typedef unsigned long sp_frame;

typedef struct sp_auxdata {
    size_t size;
    void *ptr;
} sp_auxdata;

typedef struct sp_data { 
    SPFLOAT *out;
    int sr;
    int nchan;
    unsigned long len;
    unsigned long pos;
    char filename[200];
    int k;
    uint32_t rand;
} sp_data; 

typedef struct {
    char state;
    SPFLOAT val;
} sp_param;

int sp_auxdata_alloc(sp_auxdata *aux, size_t size);
int sp_auxdata_free(sp_auxdata *aux);
int sp_auxdata_getbuf(sp_auxdata *aux, uint32_t pos, SPFLOAT *out);
int sp_auxdata_setbuf(sp_auxdata *aux, uint32_t pos, SPFLOAT *in);

int sp_create(sp_data **spp);
int sp_createn(sp_data **spp, int nchan);

int sp_destroy(sp_data **spp);
int sp_process(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));
int sp_process_raw(sp_data *sp, void *ud, void (*callback)(sp_data *, void *));

SPFLOAT sp_midi2cps(SPFLOAT nn);

int sp_set(sp_param *p, SPFLOAT val);

int sp_out(sp_data *sp, uint32_t chan, SPFLOAT val);

uint32_t sp_rand(sp_data *sp);
void sp_srand(sp_data *sp, uint32_t val);


typedef struct {
    SPFLOAT *utbl;
    int16_t *BRLow;
} sp_fft;

void sp_fft_create(sp_fft **fft);
void sp_fft_init(sp_fft *fft, int M);
void sp_fftr(sp_fft *fft, SPFLOAT *buf, int FFTsize);
void sp_ifftr(sp_fft *fft, SPFLOAT *buf, int FFTsize);
void sp_fft_destroy(sp_fft *fft);
#ifndef kiss_fft_scalar
#define kiss_fft_scalar SPFLOAT
#endif
typedef struct {
    kiss_fft_scalar r;
    kiss_fft_scalar i;
}kiss_fft_cpx;

typedef struct kiss_fft_state* kiss_fft_cfg;
typedef struct kiss_fftr_state* kiss_fftr_cfg;


