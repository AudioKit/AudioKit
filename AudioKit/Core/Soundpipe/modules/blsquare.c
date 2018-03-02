#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

float fmodf(float dummy0, float dummy1);
static float faustpower2_f(float value) {
	return (value * value);
}

typedef struct {
	float fVec2[4096];
	int iVec0[2];
	float fRec0[2];
	float fVec1[2];
	FAUSTFLOAT fHslider0;
	int fSamplingFreq;
	float fConst0;
	FAUSTFLOAT fHslider1;
	FAUSTFLOAT fHslider2;
	float fConst1;
	float fConst2;
	int IOTA;
} blsquare;

blsquare* newblsquare() {
	blsquare* dsp = (blsquare*)malloc(sizeof(blsquare));
	return dsp;
}

void deleteblsquare(blsquare* dsp) {
	free(dsp);
}


void instanceInitblsquare(blsquare* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->fHslider0 = (FAUSTFLOAT)1.;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 2); i0 = (i0 + 1)) {
			dsp->iVec0[i0] = 0;

		}

	}
	dsp->fConst0 = (float)min(192000, max(1, dsp->fSamplingFreq));
	dsp->fHslider1 = (FAUSTFLOAT)0.5;
	dsp->fHslider2 = (FAUSTFLOAT)440.;
	dsp->fConst1 = (0.25f * dsp->fConst0);
	dsp->fConst2 = (1.f / dsp->fConst0);
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec0[i1] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 2); i2 = (i2 + 1)) {
			dsp->fVec1[i2] = 0.f;

		}

	}
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int i3;
		for (i3 = 0; (i3 < 4096); i3 = (i3 + 1)) {
			dsp->fVec2[i3] = 0.f;

		}

	}

}

void initblsquare(blsquare* dsp, int samplingFreq) {
	instanceInitblsquare(dsp, samplingFreq);
}

void buildUserInterfaceblsquare(blsquare* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "frequency", &dsp->fHslider2, 440.f, 0.f, 20000.f, 0.0001f);
	interface->addHorizontalSlider(interface->uiInterface, "amp", &dsp->fHslider0, 1.f, 0.f, 1.f, 1e-05f);
	interface->addHorizontalSlider(interface->uiInterface, "width", &dsp->fHslider1, 0.5f, 0.f, 1.f, 0.f);
}

void computeblsquare(blsquare* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* output0 = outputs[0];
	float fSlow0 = (float)dsp->fHslider0;
	float fSlow1 = max((float)dsp->fHslider2, 23.4489f);
	float fSlow2 = max(0.f, min(2047.f, (dsp->fConst0 * ((float)dsp->fHslider1 / fSlow1))));
	int iSlow3 = (int)fSlow2;
	int iSlow4 = (1 + iSlow3);
	float fSlow5 = ((float)iSlow4 - fSlow2);
	float fSlow6 = (dsp->fConst1 / fSlow1);
	float fSlow7 = (dsp->fConst2 * fSlow1);
	float fSlow8 = (fSlow2 - (float)iSlow3);
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			dsp->iVec0[0] = 1;
			dsp->fRec0[0] = fmodf((dsp->fRec0[1] + fSlow7), 1.f);
			float fTemp0 = faustpower2_f(((2.f * dsp->fRec0[0]) - 1.f));
			dsp->fVec1[0] = fTemp0;
			float fTemp1 = (fSlow6 * ((fTemp0 - dsp->fVec1[1]) * (float)dsp->iVec0[1]));
			dsp->fVec2[(dsp->IOTA & 4095)] = fTemp1;
			output0[i] = (FAUSTFLOAT)(fSlow0 * (0.f - (((fSlow5 * dsp->fVec2[((dsp->IOTA - iSlow3) & 4095)]) + (fSlow8 * dsp->fVec2[((dsp->IOTA - iSlow4) & 4095)])) - fTemp1)));
			dsp->iVec0[1] = dsp->iVec0[0];
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fVec1[1] = dsp->fVec1[0];
			dsp->IOTA = (dsp->IOTA + 1);

		}

	}

}

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_blsquare *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_blsquare_create(sp_blsquare **p)
{
    *p = malloc(sizeof(sp_blsquare));
    return SP_OK;
}

int sp_blsquare_destroy(sp_blsquare **p)
{
    sp_blsquare *pp = *p;
    blsquare *dsp = pp->ud;
    deleteblsquare (dsp);
    free(*p);
    return SP_OK;
}

int sp_blsquare_init(sp_data *sp, sp_blsquare *p)
{
    blsquare *dsp = newblsquare(); UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfaceblsquare(dsp, &UI);
    initblsquare(dsp, sp->sr);


    p->freq = p->args[0];
    p->amp = p->args[1];
    p->width = p->args[2];

    p->ud = dsp;
    return SP_OK;
}

int sp_blsquare_compute(sp_data *sp, sp_blsquare *p, SPFLOAT *in, SPFLOAT *out)
{

    blsquare *dsp = p->ud;
    SPFLOAT out1 = 0;
    SPFLOAT *faust_out[] = {&out1};
    SPFLOAT *faust_in[] = {in};
    computeblsquare(dsp, 1, faust_in, faust_out);

    *out = out1;
    return SP_OK;
}
