/*
 * Drip
 * 
 * This code has been extracted from the Csound opcode "dripwater".
 * It has been modified to work as a Soundpipe module.
 * 
 * Original Author(s): Perry Cook
 * Year: 2000
 * Location: Opcodes/phisem.c
 *
 */

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "soundpipe.h"

#define WUTR_SOUND_DECAY 0.95
#define WUTR_SYSTEM_DECAY 0.996
#define WUTR_GAIN 1.0
#define WUTR_NUM_SOURCES 10.0
#define WUTR_CENTER_FREQ0 450.0
#define WUTR_CENTER_FREQ1 600.0
#define WUTR_CENTER_FREQ2 750.0
#define WUTR_RESON 0.9985
#define WUTR_FREQ_SWEEP 1.0001
#define MAX_SHAKE 2000

#ifndef M_PI
#define M_PI		3.14159265358979323846	
#endif 

static int my_random(sp_data *sp, int max)
{                      
    return (sp_rand(sp) % (max + 1));
}

static SPFLOAT noise_tick(sp_data *sp)                                        
{                       
    SPFLOAT temp;                                                                
    temp = 1.0 * sp_rand(sp) - 1073741823.5;
    return temp * (1.0 / 1073741823.0);
}                                                                              

int sp_drip_create(sp_drip **p)
{
    *p = malloc(sizeof(sp_drip));
    return SP_OK;
}

int sp_drip_destroy(sp_drip **p)
{
    free(*p);
    return SP_OK;
}

int sp_drip_init(sp_data *sp, sp_drip *p, SPFLOAT dettack)
{

    SPFLOAT temp;
    p->dettack = dettack;
    p->num_tubes = 10;
    p->damp = 0.2;
    p->shake_max = 0;
    p->freq = 450.0;
    p->freq1 = 600.0;
    p->freq2 = 720.0;
    p->amp = 0.3;

    p->sndLevel = 0.0;
    SPFLOAT tpidsr = 2.0 * M_PI / sp->sr;

    p->kloop = (sp->sr * p->dettack);
    p->outputs00 = 0.0;
    p->outputs01 = 0.0;
    p->outputs10 = 0.0;
    p->outputs11 = 0.0;
    p->outputs20 = 0.0;
    p->outputs21 = 0.0;

    p->totalEnergy = 0.0;

    p->center_freqs0 = p->res_freq0 = WUTR_CENTER_FREQ0;
    p->center_freqs1 = p->res_freq1 = WUTR_CENTER_FREQ1;
    p->center_freqs2 = p->res_freq2 = WUTR_CENTER_FREQ2;
    p->num_objectsSave = p->num_objects = WUTR_NUM_SOURCES;
    p->soundDecay = WUTR_SOUND_DECAY;
    p->systemDecay = WUTR_SYSTEM_DECAY;
    temp = log(WUTR_NUM_SOURCES) * WUTR_GAIN / WUTR_NUM_SOURCES;
    p->gains0 = p->gains1 = p->gains2 = temp;
    p->coeffs01 = WUTR_RESON * WUTR_RESON;
    p->coeffs00 = -WUTR_RESON * 2.0 *
      cos(WUTR_CENTER_FREQ0 * tpidsr);
    p->coeffs11 = WUTR_RESON * WUTR_RESON;
    p->coeffs10 = -WUTR_RESON * 2.0 *
      cos(WUTR_CENTER_FREQ1 * tpidsr);
    p->coeffs21 = WUTR_RESON * WUTR_RESON;
    p->coeffs20 = -WUTR_RESON * 2.0 *
      cos(WUTR_CENTER_FREQ2 * tpidsr);
                                
    p->shakeEnergy = p->amp * 1.0 * MAX_SHAKE * 0.1;
    p->shake_damp = 0.0;
    if (p->shakeEnergy > MAX_SHAKE) p->shakeEnergy = MAX_SHAKE;
    p->shake_maxSave = 0.0;
    p->num_objects = 10;        
    p->finalZ0 = p->finalZ1 = p->finalZ2 = 0.0;
    return SP_OK;
}

int sp_drip_compute(sp_data *sp, sp_drip *p, SPFLOAT *trig, SPFLOAT *out)
{
    SPFLOAT data;
    SPFLOAT lastOutput;

    SPFLOAT tpidsr = 2.0 * M_PI / sp->sr;

    if(*trig) {
        sp_drip_init(sp, p, p->dettack);
    } 
    if (p->num_tubes != 0.0 && p->num_tubes != p->num_objects) {
        p->num_objects = p->num_tubes;
        if (p->num_objects < 1.0) p->num_objects = 1.0;
    }
    if (p->freq != 0.0 && p->freq != p->res_freq0) {
        p->res_freq0 = p->freq;
        p->coeffs00 = -WUTR_RESON * 2.0 *
        cos(p->res_freq0 * tpidsr);
    }
    if (p->damp != 0.0 && p->damp != p->shake_damp) {
        p->shake_damp = p->damp;
        p->systemDecay = WUTR_SYSTEM_DECAY + (p->shake_damp * 0.002);
    }
    if (p->shake_max != 0.0 && p->shake_max != p->shake_maxSave) {
        p->shake_maxSave = p->shake_max;
        p->shakeEnergy += p->shake_maxSave * MAX_SHAKE * 0.1;
        if (p->shakeEnergy > MAX_SHAKE) p->shakeEnergy = MAX_SHAKE;
    }
    if (p->freq1 != 0.0 && p->freq1 != p->res_freq1) {
        p->res_freq1 = p->freq1;
        p->coeffs10 = -WUTR_RESON * 2.0 *
        cos(p->res_freq1 * tpidsr);
    }
    if (p->freq2 != 0.0 && p->freq2 != p->res_freq2) {
        p->res_freq2 = p->freq2;
        p->coeffs20 = -WUTR_RESON * 2.0 *
        cos(p->res_freq2 * tpidsr);
    }
    if ((--p->kloop) == 0) {
        p->shakeEnergy = 0.0;
    }

    SPFLOAT shakeEnergy = p->shakeEnergy;
    SPFLOAT systemDecay = p->systemDecay;
    SPFLOAT sndLevel = p->sndLevel;
    SPFLOAT num_objects = p->num_objects;
    SPFLOAT soundDecay = p->soundDecay;
    SPFLOAT inputs0, inputs1, inputs2;

    shakeEnergy *= systemDecay; /* Exponential system decay */

    sndLevel = shakeEnergy;
    if (my_random(sp, 32767) < num_objects) {
        int j;
        j = my_random(sp, 3);
        if (j == 0) {
            p->center_freqs0 = p->res_freq1 *
            (0.75 + (0.25 * noise_tick(sp)));
            p->gains0 = fabs(noise_tick(sp));
        } else if (j == 1) {
            p->center_freqs1 = p->res_freq1 *
            (1.0 + (0.25 * noise_tick(sp)));
            p->gains1 = fabs(noise_tick(sp));
        } else  {
            p->center_freqs2 = p->res_freq1 *
            (1.25 + (0.25 * noise_tick(sp)));
            p->gains2 = fabs(noise_tick(sp));
        }
    }

    p->gains0 *= WUTR_RESON;
    if (p->gains0 > 0.001) {
        p->center_freqs0  *= WUTR_FREQ_SWEEP;
        p->coeffs00 = -WUTR_RESON * 2.0 *
        cos(p->center_freqs0 * tpidsr);
    }
    p->gains1 *= WUTR_RESON;
    if (p->gains1 > 0.00) {
        p->center_freqs1 *= WUTR_FREQ_SWEEP;
        p->coeffs10 = -WUTR_RESON * 2.0 *
        cos(p->center_freqs1 * tpidsr);
    }
    p->gains2 *= WUTR_RESON;
    if (p->gains2 > 0.001) {
        p->center_freqs2 *= WUTR_FREQ_SWEEP;
        p->coeffs20 = -WUTR_RESON * 2.0 *
        cos(p->center_freqs2 * tpidsr);
    }

    sndLevel *= soundDecay;   
    inputs0 = sndLevel;
    inputs0 *= noise_tick(sp); 
    inputs1 = inputs0 * p->gains1;
    inputs2 = inputs0 * p->gains2;
    inputs0 *= p->gains0;
    inputs0 -= p->outputs00*p->coeffs00;
    inputs0 -= p->outputs01*p->coeffs01;
    p->outputs01 = p->outputs00;
    p->outputs00 = inputs0;
    data = p->gains0*p->outputs00;
    inputs1 -= p->outputs10*p->coeffs10;
    inputs1 -= p->outputs11*p->coeffs11;
    p->outputs11 = p->outputs10;
    p->outputs10 = inputs1;
    data += p->gains1*p->outputs10;
    inputs2-= p->outputs20*p->coeffs20;
    inputs2 -= p->outputs21*p->coeffs21;
    p->outputs21 = p->outputs20;
    p->outputs20 = inputs2;
    data += p->gains2*p->outputs20;

    p->finalZ2 = p->finalZ1;
    p->finalZ1 = p->finalZ0;
    p->finalZ0 = data * 4.0;

    lastOutput = p->finalZ2 - p->finalZ0;
    lastOutput *= 0.005;
    *out = lastOutput;
    p->shakeEnergy = shakeEnergy;
    p->sndLevel = sndLevel;
    return SP_OK;
}
