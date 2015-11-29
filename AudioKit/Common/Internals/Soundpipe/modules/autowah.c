#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif  


float expf(float dummy0);
float fabsf(float dummy0);
float powf(float dummy0, float dummy1);
float cosf(float dummy0);
static float faustpower2_f(float value) {
	return (value * value);
}

typedef struct {
	
	float fRec0[3];
	float fRec3[2];
	float fRec2[2];
	float fRec1[2];
	float fRec4[2];
	float fRec5[2];
	FAUSTFLOAT fVslider0;
	int fSamplingFreq;
	int iConst0;
	float fConst1;
	float fConst2;
	float fConst3;
	float fConst4;
	float fConst5;
	float fConst6;
	FAUSTFLOAT fVslider1;
	FAUSTFLOAT fVslider2;
	
} autowah;

autowah* newautowah() { 
	autowah* dsp = (autowah*)malloc(sizeof(autowah));
	return dsp;
}

void deleteautowah(autowah* dsp) { 
	free(dsp);
}

void instanceInitautowah(autowah* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->fVslider0 = (FAUSTFLOAT)0.;
	dsp->iConst0 = min(192000, max(1, dsp->fSamplingFreq));
	dsp->fConst1 = (1413.72f / (float)dsp->iConst0);
	dsp->fConst2 = expf((0.f - (100.f / (float)dsp->iConst0)));
	dsp->fConst3 = (1.f - dsp->fConst2);
	dsp->fConst4 = expf((0.f - (10.f / (float)dsp->iConst0)));
	dsp->fConst5 = (1.f - dsp->fConst4);
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 2); i0 = (i0 + 1)) {
			dsp->fRec3[i0] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec2[i1] = 0.f;
			
		}
		
	}
	dsp->fConst6 = (2827.43f / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 2); i2 = (i2 + 1)) {
			dsp->fRec1[i2] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i3;
		for (i3 = 0; (i3 < 2); i3 = (i3 + 1)) {
			dsp->fRec4[i3] = 0.f;
			
		}
		
	}
	dsp->fVslider1 = (FAUSTFLOAT)100.;
	dsp->fVslider2 = (FAUSTFLOAT)0.1;
	/* C99 loop */
	{
		int i4;
		for (i4 = 0; (i4 < 2); i4 = (i4 + 1)) {
			dsp->fRec5[i4] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i5;
		for (i5 = 0; (i5 < 3); i5 = (i5 + 1)) {
			dsp->fRec0[i5] = 0.f;
			
		}
		
	}
	
}

void initautowah(autowah* dsp, int samplingFreq) {
	instanceInitautowah(dsp, samplingFreq);
}

void buildUserInterfaceautowah(autowah* dsp, UIGlue* interface) {
	interface->addVerticalSlider(interface->uiInterface, "level", &dsp->fVslider2, 0.1f, 0.f, 1.f, 0.01f);
	interface->addVerticalSlider(interface->uiInterface, "wah", &dsp->fVslider0, 0.f, 0.f, 1.f, 0.01f);
	interface->addVerticalSlider(interface->uiInterface, "wet_dry", &dsp->fVslider1, 100.f, 0.f, 100.f, 1.f);
}

void computeautowah(autowah* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* output0 = outputs[0];
	float fSlow0 = (float)dsp->fVslider0;
	float fSlow1 = (float)dsp->fVslider1;
	float fSlow2 = (0.01f * (fSlow1 * (float)dsp->fVslider2));
	float fSlow3 = ((1.f - (0.01f * fSlow1)) + (1.f - fSlow0));
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			float fTemp0 = (float)input0[i];
			float fTemp1 = fabsf(fTemp0);
			dsp->fRec3[0] = max(fTemp1, ((dsp->fConst4 * dsp->fRec3[1]) + (dsp->fConst5 * fTemp1)));
			dsp->fRec2[0] = ((dsp->fConst2 * dsp->fRec2[1]) + (dsp->fConst3 * dsp->fRec3[0]));
			float fTemp2 = min(1.f, dsp->fRec2[0]);
			float fTemp3 = powf(2.f, (2.3f * fTemp2));
			float fTemp4 = (1.f - (dsp->fConst1 * (fTemp3 / powf(2.f, (1.f + (2.f * (1.f - fTemp2)))))));
			dsp->fRec1[0] = ((0.999f * dsp->fRec1[1]) + (0.001f * (0.f - (2.f * (fTemp4 * cosf((dsp->fConst6 * fTemp3)))))));
			dsp->fRec4[0] = ((0.999f * dsp->fRec4[1]) + (0.001f * faustpower2_f(fTemp4)));
			dsp->fRec5[0] = ((0.999f * dsp->fRec5[1]) + (0.0001f * powf(4.f, fTemp2)));
			dsp->fRec0[0] = (0.f - (((dsp->fRec1[0] * dsp->fRec0[1]) + (dsp->fRec4[0] * dsp->fRec0[2])) - (fSlow2 * (dsp->fRec5[0] * fTemp0))));
			output0[i] = (FAUSTFLOAT)((fSlow0 * (dsp->fRec0[0] - dsp->fRec0[1])) + (fSlow3 * fTemp0));
			dsp->fRec3[1] = dsp->fRec3[0];
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fRec4[1] = dsp->fRec4[0];
			dsp->fRec5[1] = dsp->fRec5[0];
			dsp->fRec0[2] = dsp->fRec0[1];
			dsp->fRec0[1] = dsp->fRec0[0];
		}
		
	}
	
}

static void addVerticalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_autowah *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_autowah_create(sp_autowah **p)
{
    *p = malloc(sizeof(sp_autowah));
    return SP_OK;
}

int sp_autowah_destroy(sp_autowah **p)
{
    sp_autowah *pp = *p;
    autowah *dsp = pp->faust;
    deleteautowah (dsp);
    free(*p);
    return SP_OK;
}

int sp_autowah_init(sp_data *sp, sp_autowah *p)
{
    autowah *dsp = newautowah(); 
    UIGlue UI;
    p->argpos = 0;
    UI.addVerticalSlider= addVerticalSlider;
    UI.uiInterface = p;
    buildUserInterfaceautowah(dsp, &UI);
    initautowah(dsp, sp->sr);
    
    p->level = p->args[0]; 
    p->wah = p->args[1]; 
    p->mix = p->args[2];

    p->faust = dsp;
    return SP_OK;
}

int sp_autowah_compute(sp_data *sp, sp_autowah *p, SPFLOAT *in, SPFLOAT *out) 
{
    autowah *dsp = p->faust;
    SPFLOAT *faust_out[] = {out};
    SPFLOAT *faust_in[] = {in};
    computeautowah(dsp, 1, faust_in, faust_out);
    return SP_OK;
}
