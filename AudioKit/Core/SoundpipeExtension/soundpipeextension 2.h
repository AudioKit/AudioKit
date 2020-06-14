#ifndef SOUNDPIPEEXTENSION_H
#define SOUNDPIPEEXTENSION_H
#include "soundpipe.h"

// Extension of Soundpipe library specific to AK

typedef struct {
    SPFLOAT freq, amp, iphs;
    int32_t lphs;
    sp_ftbl **tbl;
    int inc;
    SPFLOAT wtpos;
    int nft; // number of waveforms
    int nbl; // number of bandlimited tables per waveform
    float *fbl; // array of frequencies per bandlimited waveform
    int enableBandlimit; // if 0 use index 0, if 1 select index based on freq
    int bandlimitIndexOverride; // temporary
} sp_oscmorph2d;

int sp_oscmorph2d_create(sp_oscmorph2d **p);
int sp_oscmorph2d_destroy(sp_oscmorph2d **p);
int sp_oscmorph2d_init(sp_data *sp, sp_oscmorph2d *osc, sp_ftbl **ft, int nft, int nbl, float *fbls, SPFLOAT iphs);
int sp_oscmorph2d_compute(sp_data *sp, sp_oscmorph2d *p, SPFLOAT *in, SPFLOAT *out);

#endif
