/*
 * WPKorg35
 * 
 * This is a filter based off of an implemenation the Korg35 filter by Will
 * Pirke. It has been ported from the CCRMA chugin by the same name.
 * 
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"

#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

static void update(sp_data *sp, sp_wpkorg35 *wpk)
{
	/* prewarp for BZT */
	SPFLOAT wd = 2*M_PI*wpk->cutoff;          
	SPFLOAT T  = 1.0/(SPFLOAT)sp->sr;             
	SPFLOAT wa = (2/T)*tan(wd*T/2); 
	SPFLOAT g  = wa*T/2.0;    

	/* the feedforward coeff in the VA One Pole */
	SPFLOAT G = g/(1.0 + g);

    /* set alphas */
    wpk->lpf1_a = G;
    wpk->lpf2_a = G;
    wpk->hpf_a = G;

    /* set betas */
	wpk->lpf2_b = (wpk->res - wpk->res*G)/(1.0 + g);
	wpk->hpf_b = -1.0/(1.0 + g);

	wpk->alpha = 1.0/(1.0 - wpk->res*G + wpk->res*G*G); ;
}

SPFLOAT wpk_doFilter(sp_wpkorg35 *wpk)
{
    return 0.0;
}

int sp_wpkorg35_create(sp_wpkorg35 **p)
{
    *p = malloc(sizeof(sp_wpkorg35));
    return SP_OK;
}

int sp_wpkorg35_destroy(sp_wpkorg35 **p)
{
    free(*p);
    return SP_OK;
}

int sp_wpkorg35_init(sp_data *sp, sp_wpkorg35 *p)
{
    p->alpha = 0.0;
    p->pcutoff = p->cutoff = 1000; 
    p->pres = p->res = 1.0; 

    /* reset memory for filters */
    p->lpf1_z = 0;
    p->lpf2_z = 0;
    p->hpf_z = 0;


    /* initialize LPF1 */

    p->lpf1_a = 1.0;
    p->lpf1_z = 0.0;
    
    /* initialize LPF2 */

    p->lpf2_a = 1.0;
    p->lpf2_b = 1.0;
    p->lpf2_z = 0.0;

    p->nonlinear = 0;

    /* update filters */
    update(sp, p);
    return SP_OK;
}

int sp_wpkorg35_compute(sp_data *sp, sp_wpkorg35 *p, SPFLOAT *in, SPFLOAT *out)
{
    /* TODO: add previous values */

    if(p->pcutoff != p->cutoff || p->pres != p->res) update(sp, p);

    /* initialize variables */
    SPFLOAT y1 = 0.0;
    SPFLOAT S35 = 0.0;
    SPFLOAT u = 0.0;
    SPFLOAT y = 0.0;
    SPFLOAT vn = 0.0;

    /* process input through LPF1 */
    vn = (*in - p->lpf1_z) * p->lpf1_a;
    y1 = vn + p->lpf1_z;
    p->lpf1_z = y1 + vn;

    /* form feedback value */
    
    S35 = (p->hpf_z * p->hpf_b) + (p->lpf2_z * p->lpf2_b); 

    /* Calculate u */
    u = p->alpha * (y1 + S35);

    /* Naive NLP */

    if(p->saturation > 0) {
        u = tanh(p->saturation * u);
    }

    /* Feed it to LPF2 */
    vn = (u - p->lpf2_z) * p->lpf2_a;
    y = (vn + p->lpf2_z);
    p->lpf2_z = y + vn;
    y *= p->res;

    /* Feed y to HPF2 */

    vn = (y - p->hpf_z) * p->hpf_a;
    p->hpf_z = vn + (vn + p->hpf_z); 

    /* Auto-normalize */

    if(p->res > 0) {
        y *= 1.0 / p->res;
    }

    *out = y;

    p->pcutoff = p->cutoff;
    p->pres = p->res;
    return SP_OK;
}
