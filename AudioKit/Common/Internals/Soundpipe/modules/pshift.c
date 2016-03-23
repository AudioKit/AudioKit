#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

#ifndef FAUSTFLOAT
#define FAUSTFLOAT SPFLOAT
#endif  


float powf(float dummy0, float dummy1);
float fmodf(float dummy0, float dummy1);

typedef struct {
	float fVec0[65536];
	float fRec0[2];
	int IOTA;
	FAUSTFLOAT fHslider0;
	FAUSTFLOAT fHslider1;
	FAUSTFLOAT fHslider2;
	int fSamplingFreq;
} pshift;

static pshift* newpshift() { 
	pshift* dsp = (pshift*)malloc(sizeof(pshift));
	return dsp;
}

static void deletepshift(pshift* dsp) { 
	free(dsp);
}

static void instanceInitpshift(pshift* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 65536); i0 = (i0 + 1)) {
			dsp->fVec0[i0] = 0.f;
			
		}
		
	}
	dsp->fHslider0 = (FAUSTFLOAT)1000.;
	dsp->fHslider1 = (FAUSTFLOAT)0.;
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec0[i1] = 0.f;
			
		}
		
	}
	dsp->fHslider2 = (FAUSTFLOAT)10.;
}

static void initpshift(pshift* dsp, int samplingFreq) {
	instanceInitpshift(dsp, samplingFreq);
}

static void buildUserInterfacepshift(pshift* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "shift", &dsp->fHslider1, 0.f, -24.f, 24.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "window", &dsp->fHslider0, 1000.f, 50.f, 10000.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "xfade", &dsp->fHslider2, 10.f, 1.f, 10000.f, 1.f);
}

static void computepshift(pshift* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* output0 = outputs[0];
	float fSlow0 = (float)dsp->fHslider0;
	float fSlow1 = ((1.f + fSlow0) - powf(2.f, (0.0833333f * (float)dsp->fHslider1)));
	float fSlow2 = (1.f / (float)dsp->fHslider2);
	float fSlow3 = (fSlow0 - 1.f);
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			float fTemp0 = (float)input0[i];
			dsp->fVec0[(dsp->IOTA & 65535)] = fTemp0;
			dsp->fRec0[0] = fmodf((dsp->fRec0[1] + fSlow1), fSlow0);
			int iTemp1 = (int)dsp->fRec0[0];
			int iTemp2 = (1 + iTemp1);
			float fTemp3 = min((fSlow2 * dsp->fRec0[0]), 1.f);
			float fTemp4 = (dsp->fRec0[0] + fSlow0);
			int iTemp5 = (int)fTemp4;
			output0[i] = (FAUSTFLOAT)((((dsp->fVec0[((dsp->IOTA - (iTemp1 & 65535)) & 65535)] * ((float)iTemp2 - dsp->fRec0[0])) + ((dsp->fRec0[0] - (float)iTemp1) * dsp->fVec0[((dsp->IOTA - (iTemp2 & 65535)) & 65535)])) * fTemp3) + (((dsp->fVec0[((dsp->IOTA - (iTemp5 & 65535)) & 65535)] * (0.f - ((dsp->fRec0[0] + fSlow3) - (float)iTemp5))) + ((fTemp4 - (float)iTemp5) * dsp->fVec0[((dsp->IOTA - ((1 + iTemp5) & 65535)) & 65535)])) * (1.f - fTemp3)));
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec0[1] = dsp->fRec0[0];
			
		}
		
	}
	
}

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_pshift *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_pshift_create(sp_pshift **p)
{
    *p = malloc(sizeof(sp_pshift));
    return SP_OK;
}

int sp_pshift_destroy(sp_pshift **p)
{
    sp_pshift *pp = *p;
    pshift *dsp = pp->faust;
    deletepshift (dsp);
    free(*p);
    return SP_OK;
}

int sp_pshift_init(sp_data *sp, sp_pshift *p)
{
    pshift *dsp = newpshift(); 
    UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfacepshift(dsp, &UI);
    initpshift(dsp, sp->sr);

     
    p->shift = p->args[0]; 
    p->window = p->args[1]; 
    p->xfade = p->args[2];

    p->faust = dsp;
    return SP_OK;
}

int sp_pshift_compute(sp_data *sp, sp_pshift *p, SPFLOAT *in, SPFLOAT *out) 
{

    pshift *dsp = p->faust;
    SPFLOAT out1 = 0;
    SPFLOAT *faust_out[] = {&out1};
    SPFLOAT *faust_in[] = {in};
    computepshift(dsp, 1, faust_in, faust_out);

    *out = out1;
    return SP_OK;
}
