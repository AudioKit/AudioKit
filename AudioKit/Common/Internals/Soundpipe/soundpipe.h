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


typedef struct {
    SPFLOAT incr;
    SPFLOAT index;
    int32_t sample_index;
    SPFLOAT value;
} sp_fold;

int sp_fold_create(sp_fold **p);
int sp_fold_destroy(sp_fold **p);
int sp_fold_init(sp_data *sp, sp_fold *p);
int sp_fold_compute(sp_data *sp, sp_fold *p, SPFLOAT *in, SPFLOAT *out);
#define SP_FT_MAXLEN 0x1000000L
#define SP_FT_PHMASK 0x0FFFFFFL

typedef struct sp_ftbl{
    size_t size;
    uint32_t lobits;
    uint32_t lomask;
    SPFLOAT lodiv;
    SPFLOAT sicvt;
    SPFLOAT *tbl;
}sp_ftbl;

int sp_ftbl_create(sp_data *sp, sp_ftbl **ft, size_t size);
int sp_ftbl_destroy(sp_ftbl **ft);

int sp_gen_vals(sp_data *sp, sp_ftbl *ft, const char *string);

int sp_gen_sine(sp_data *sp, sp_ftbl *ft);
int sp_gen_file(sp_data *sp, sp_ftbl *ft, const char *filename);
int sp_gen_sinesum(sp_data *sp, sp_ftbl *ft, const char *argstring);
int sp_gen_line(sp_data *sp, sp_ftbl *ft, const char *argstring);
int sp_gen_xline(sp_data *sp, sp_ftbl *ft, const char *argstring);
int sp_gen_gauss(sp_data *sp, sp_ftbl *ft, SPFLOAT scale, uint32_t seed);

int sp_ftbl_loadfile(sp_data *sp, sp_ftbl **ft, const char *filename);
typedef struct {
    int mti;
    /* do not change value 624 */
    uint32_t mt[624];
} sp_randmt;

void sp_randmt_seed(sp_randmt *p,
    const uint32_t *initKey, uint32_t keyLength);

uint32_t sp_randmt_compute(sp_randmt *p);
typedef struct {
    SPFLOAT revtime, looptime;
    SPFLOAT coef, prvt;
    sp_auxdata aux;
    uint32_t bufpos;
    uint32_t bufsize;
} sp_allpass;

int sp_allpass_create(sp_allpass **p);
int sp_allpass_destroy(sp_allpass **p);
int sp_allpass_init(sp_data *sp, sp_allpass *p, SPFLOAT looptime);
int sp_allpass_compute(sp_data *sp, sp_allpass *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT hp;
    SPFLOAT c1, c2, yt1, prvhp;
    SPFLOAT tpidsr;
} sp_atone;

int sp_atone_create(sp_atone **p);
int sp_atone_destroy(sp_atone **p);
int sp_atone_init(sp_data *sp, sp_atone *p);
int sp_atone_compute(sp_data *sp, sp_atone *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT sr, freq, bw, istor;
    SPFLOAT lkf, lkb;
    SPFLOAT a[8];
    SPFLOAT pidsr, tpidsr;
} sp_butbr;

int sp_butbr_create(sp_butbr **p);
int sp_butbr_destroy(sp_butbr **p);
int sp_butbr_init(sp_data *sp, sp_butbr *p);
int sp_butbr_compute(sp_data *sp, sp_butbr *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT sr, freq, bw, istor;
    SPFLOAT lkf, lkb;
    SPFLOAT a[8];
    SPFLOAT pidsr, tpidsr;
} sp_butbp;

int sp_butbp_create(sp_butbp **p);
int sp_butbp_destroy(sp_butbp **p);
int sp_butbp_init(sp_data *sp, sp_butbp *p);
int sp_butbp_compute(sp_data *sp, sp_butbp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct  {
    SPFLOAT sr, freq, istor;
    SPFLOAT lkf;
    SPFLOAT a[8];
    SPFLOAT pidsr;
} sp_buthp;

int sp_buthp_create(sp_buthp **p);
int sp_buthp_destroy(sp_buthp **p);
int sp_buthp_init(sp_data *sp, sp_buthp *p);
int sp_buthp_compute(sp_data *sp, sp_buthp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct  {
    SPFLOAT sr, freq, istor;
    SPFLOAT lkf;
    SPFLOAT a[8];
    SPFLOAT pidsr;
} sp_butlp;

int sp_butlp_create(sp_butlp **p);
int sp_butlp_destroy(sp_butlp **p);
int sp_butlp_init(sp_data *sp, sp_butlp *p);
int sp_butlp_compute(sp_data *sp, sp_butlp *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT arg, lim, k1, k2;
    int meth;
}sp_clip;

int sp_clip_create(sp_clip **p);
int sp_clip_destroy(sp_clip **p);
int sp_clip_init(sp_data *sp, sp_clip *p);
int sp_clip_compute(sp_data *sp, sp_clip *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_comb{
    SPFLOAT revtime, looptime;
    SPFLOAT coef, prvt;
    sp_auxdata aux;
    uint32_t bufpos;
    uint32_t bufsize;
} sp_comb;

int sp_comb_create(sp_comb **p);
int sp_comb_destroy(sp_comb **p);
int sp_comb_init(sp_data *sp, sp_comb *p, SPFLOAT looptime);
int sp_comb_compute(sp_data *sp, sp_comb *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT gg;
    SPFLOAT outputs;
    SPFLOAT inputs;
    SPFLOAT gain;
} sp_dcblock;

int sp_dcblock_create(sp_dcblock **p);
int sp_dcblock_destroy(sp_dcblock **p);
int sp_dcblock_init(sp_data *sp, sp_dcblock *p);
int sp_dcblock_compute(sp_data *sp, sp_dcblock *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT bitdepth;
    SPFLOAT srate;
    sp_fold *fold;
} sp_bitcrush;

int sp_bitcrush_create(sp_bitcrush **p);
int sp_bitcrush_destroy(sp_bitcrush **p);
int sp_bitcrush_init(sp_data *sp, sp_bitcrush *p);
int sp_bitcrush_compute(sp_data *sp, sp_bitcrush *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT time;
    SPFLOAT feedback;
    SPFLOAT last;
    sp_auxdata buf;
    uint32_t bufsize;
    uint32_t bufpos;
    int init;
} sp_delay;

int sp_delay_create(sp_delay **p);
int sp_delay_destroy(sp_delay **p);
int sp_delay_init(sp_data *sp, sp_delay *p, SPFLOAT time);
int sp_delay_compute(sp_data *sp, sp_delay *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_dist{
    SPFLOAT pregain, postgain, shape1, shape2, mode;
} sp_dist;

int sp_dist_create(sp_dist **p);
int sp_dist_destroy(sp_dist **p);
int sp_dist_init(sp_data *sp, sp_dist *p);
int sp_dist_compute(sp_data *sp, sp_dist *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
  SPFLOAT freq, bw, gain;
  SPFLOAT z1,z2, sr;
  SPFLOAT frv, bwv;
  SPFLOAT c,d;
} sp_eqfil;

int sp_eqfil_create(sp_eqfil **p);
int sp_eqfil_destroy(sp_eqfil **p);
int sp_eqfil_init(sp_data *sp, sp_eqfil *p);
int sp_eqfil_compute(sp_data *sp, sp_eqfil *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT freq, atk, dec, istor;
    SPFLOAT tpidsr;
    SPFLOAT sr;
    SPFLOAT delay[4];
}sp_fofilt;

int sp_fofilt_create(sp_fofilt **t);
int sp_fofilt_destroy(sp_fofilt **t);
int sp_fofilt_init(sp_data *sp, sp_fofilt *p);
int sp_fofilt_compute(sp_data *sp, sp_fofilt *p, SPFLOAT *in, SPFLOAT *out);

typedef struct sp_fosc{
    SPFLOAT amp, freq, car, mod, indx, iphs;
    int32_t mphs, cphs;
    sp_ftbl *ft;
} sp_fosc;

int sp_fosc_create(sp_fosc **p);
int sp_fosc_destroy(sp_fosc **p);
int sp_fosc_init(sp_data *sp, sp_fosc *p, sp_ftbl *ft);
int sp_fosc_compute(sp_data *sp, sp_fosc *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *ud;
} sp_jcrev;

int sp_jcrev_create(sp_jcrev **p);
int sp_jcrev_destroy(sp_jcrev **p);
int sp_jcrev_init(sp_data *sp, sp_jcrev *p);
int sp_jcrev_compute(sp_data *sp, sp_jcrev *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_lpf18{
    SPFLOAT cutoff, res, dist;
    SPFLOAT ay1, ay2, aout, lastin, onedsr;
} sp_lpf18;

int sp_lpf18_create(sp_lpf18 **p);
int sp_lpf18_destroy(sp_lpf18 **p);
int sp_lpf18_init(sp_data *sp, sp_lpf18 *p);
int sp_lpf18_compute(sp_data *sp, sp_lpf18 *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT freq, q, xnm1, ynm1, ynm2, a0, a1, a2, d, lfq, lq;
    SPFLOAT sr;
}sp_mode;

int sp_mode_create(sp_mode **p);
int sp_mode_destroy(sp_mode **p);
int sp_mode_init(sp_data *sp, sp_mode *p);
int sp_mode_compute(sp_data *sp, sp_mode *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT freq;
    SPFLOAT res;
    SPFLOAT istor;

    SPFLOAT delay[6];
    SPFLOAT tanhstg[3];
    SPFLOAT oldfreq;
    SPFLOAT oldres;
    SPFLOAT oldacr;
    SPFLOAT oldtune;
} sp_moogladder;

int sp_moogladder_create(sp_moogladder **t);
int sp_moogladder_destroy(sp_moogladder **t);
int sp_moogladder_init(sp_data *sp, sp_moogladder *p);
int sp_moogladder_compute(sp_data *sp, sp_moogladder *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT amp;
}sp_noise;

int sp_noise_create(sp_noise **ns);
int sp_noise_init(sp_data *sp, sp_noise *ns);
int sp_noise_compute(sp_data *sp, sp_noise *ns, SPFLOAT *in, SPFLOAT *out);
int sp_noise_destroy(sp_noise **ns);
typedef struct {
    SPFLOAT freq, amp, iphs;
    int32_t   lphs;
    sp_ftbl *tbl;
    int inc;
} sp_osc;

int sp_osc_create(sp_osc **osc);
int sp_osc_destroy(sp_osc **osc);
int sp_osc_init(sp_data *sp, sp_osc *osc, sp_ftbl *ft, SPFLOAT iphs);
int sp_osc_compute(sp_data *sp, sp_osc *osc, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT fc, v, q, mode;

    SPFLOAT xnm1, xnm2, ynm1, ynm2;
    SPFLOAT prv_fc, prv_v, prv_q;
    SPFLOAT b0, b1, b2, a1, a2;
    SPFLOAT tpidsr;
    int imode;
} sp_pareq;

int sp_pareq_create(sp_pareq **p);
int sp_pareq_destroy(sp_pareq **p);
int sp_pareq_init(sp_data *sp, sp_pareq *p);
int sp_pareq_compute(sp_data *sp, sp_pareq *p, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_phasor{
    SPFLOAT freq, phs;
    SPFLOAT curphs, onedsr;
} sp_phasor;

int sp_phasor_create(sp_phasor **p);
int sp_phasor_destroy(sp_phasor **p);
int sp_phasor_init(sp_data *sp, sp_phasor *p, SPFLOAT iphs);
int sp_phasor_compute(sp_data *sp, sp_phasor *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
size_t size;
void *auxp;
}auxData;
typedef struct {
    int     writePos;
    int     bufferSize;
    int     readPos;
    int     readPosFrac;
    int     readPosFrac_inc;
    int     dummy;
    int     seedVal;
    int     randLine_cnt;
    SPFLOAT filterState;
    SPFLOAT *buf;
} sp_revsc_dl;

typedef struct  {
    SPFLOAT feedback, lpfreq;
    SPFLOAT iSampleRate, iPitchMod, iSkipInit;
    SPFLOAT sampleRate;
    SPFLOAT dampFact;
    SPFLOAT prv_LPFreq;
    int initDone;
    sp_revsc_dl delayLines[8];
    sp_auxdata aux;
} sp_revsc;

int sp_revsc_create(sp_revsc **p);
int sp_revsc_destroy(sp_revsc **p);
int sp_revsc_init(sp_data *sp, sp_revsc *p);
int sp_revsc_compute(sp_data *sp, sp_revsc *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out1, SPFLOAT *out2);
typedef struct sp_rms{
    SPFLOAT ihp, istor;
    SPFLOAT c1, c2, prvq;
} sp_rms;

int sp_rms_create(sp_rms **p);
int sp_rms_destroy(sp_rms **p);
int sp_rms_init(sp_data *sp, sp_rms *p);
int sp_rms_compute(sp_data *sp, sp_rms *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    void *ud;
    int argpos;
    SPFLOAT *args[2];
    SPFLOAT *freq;
    SPFLOAT *amp;
} sp_saw;

int sp_saw_create(sp_saw **p);
int sp_saw_destroy(sp_saw **p);
int sp_saw_init(sp_data *sp, sp_saw *p);
int sp_saw_compute(sp_data *sp, sp_saw *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT inmin, inmax, outmin, outmax;
} sp_scale;

int sp_scale_create(sp_scale **p);
int sp_scale_destroy(sp_scale **p);
int sp_scale_init(sp_data *sp, sp_scale *p);
int sp_scale_compute(sp_data *sp, sp_scale *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT freq, fdbgain;
    SPFLOAT LPdelay, APdelay;
    SPFLOAT *Cdelay;
    sp_auxdata buf;
    int wpointer, rpointer, size;
}sp_streson;

int sp_streson_create(sp_streson **p);
int sp_streson_destroy(sp_streson **p);
int sp_streson_init(sp_data *sp, sp_streson *p);
int sp_streson_compute(sp_data *sp, sp_streson *p, SPFLOAT *in, SPFLOAT *out);
typedef struct{
    SPFLOAT fco, res, dist, asym, iskip, y, y1, y2;
    int fcocod, rezcod;
    SPFLOAT sr;
    SPFLOAT onedsr;

}sp_tbvcf;

int sp_tbvcf_create(sp_tbvcf **p);
int sp_tbvcf_destroy(sp_tbvcf **p);
int sp_tbvcf_init(sp_data *sp, sp_tbvcf *p);
int sp_tbvcf_compute(sp_data *sp, sp_tbvcf *p, SPFLOAT *in, SPFLOAT *out);
typedef struct {
    SPFLOAT hp;
    SPFLOAT c1, c2, yt1, prvhp;
    SPFLOAT tpidsr;
} sp_tone;

int sp_tone_create(sp_tone **t);
int sp_tone_destroy(sp_tone **t);
int sp_tone_init(sp_data *sp, sp_tone *t);
int sp_tone_compute(sp_data *sp, sp_tone *t, SPFLOAT *in, SPFLOAT *out);
typedef struct sp_vdelay{
    SPFLOAT del, maxdel;
    SPFLOAT sr;
    sp_auxdata buf;
    int32_t left;
} sp_vdelay;

int sp_vdelay_create(sp_vdelay **p);
int sp_vdelay_destroy(sp_vdelay **p);
int sp_vdelay_init(sp_data *sp, sp_vdelay *p, SPFLOAT maxdel);
int sp_vdelay_compute(sp_data *sp, sp_vdelay *p, SPFLOAT *in, SPFLOAT *out);
