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
	float fRec1[2];
	float fVec1[2];
	float fRec0[2];
	int fSamplingFreq;
	int iConst0;
	float fConst1;
	FAUSTFLOAT fHslider0;
	FAUSTFLOAT fHslider1;
    FAUSTFLOAT fHslider2;
	float fConst2;
	float fConst3;
	float fConst4;
	int IOTA;

} bltriangle;

bltriangle* newbltriangle() {
	bltriangle* dsp = (bltriangle*)malloc(sizeof(bltriangle));
	return dsp;
}

void deletebltriangle(bltriangle* dsp) {
	free(dsp);
}

void instanceInitbltriangle(bltriangle* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 2); i0 = (i0 + 1)) {
			dsp->iVec0[i0] = 0;

		}

	}
	dsp->iConst0 = min(192000, max(1, dsp->fSamplingFreq));
	dsp->fConst1 = (4.f / (float)dsp->iConst0);
	dsp->fHslider0 = (FAUSTFLOAT)440.;
	dsp->fHslider1 = (FAUSTFLOAT)1.;
    dsp->fHslider2 = (FAUSTFLOAT)0.5;
	dsp->fConst2 = (float)dsp->iConst0;
	dsp->fConst3 = (0.25f * dsp->fConst2);
	dsp->fConst4 = (1.f / dsp->fConst2);
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec1[i1] = 0.f;

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
	/* C99 loop */
	{
		int i4;
		for (i4 = 0; (i4 < 2); i4 = (i4 + 1)) {
			dsp->fRec0[i4] = 0.f;

		}

	}

}

void initbltriangle(bltriangle* dsp, int samplingFreq) {
	instanceInitbltriangle(dsp, samplingFreq);
}

void buildUserInterfacebltriangle(bltriangle* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "freq", &dsp->fHslider0, 440.f, 0.f, 20000.f, 0.0001f);
	interface->addHorizontalSlider(interface->uiInterface, "amp", &dsp->fHslider1, 1.f, 0.f, 1.f, 1e-05f);
    interface->addHorizontalSlider(interface->uiInterface, "crest", &dsp->fHslider2, 0.5f, .05f, .95f, .001f);
}

float computeampangle(bltriangle* dsp) {
    float ampAngle = 0.5f;
    printf("Crest Val: %f", dsp->fHslider2);
    if ((float)dsp->fHslider2<=.95f && (float)dsp->fHslider2>=.05f) {
        if ((float)dsp->fHslider2<=0.5f) {
            ampAngle = fabsf(.5f-(float)dsp->fHslider2);
            
        } else {
            ampAngle = fabsf((float)dsp->fHslider2-.5f);
        }
    }
    return ampAngle;
}

void computebltriangle(bltriangle* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* output0 = outputs[0];
    float ampAngle = computeampangle(dsp);
	float fSlow0 = (float)dsp->fHslider0;
	float fSlow1 = (dsp->fConst1 * (fSlow0 * (((float)dsp->fHslider1)/cosf(M_PI*ampAngle))));
	float fSlow2 = max(fSlow0, 23.4489f);
	float fSlow3 = max(0.f, min(2047.f, ((float)dsp->fHslider2 * dsp->fConst2 / fSlow2)));
	int iSlow4 = (int)fSlow3;
	int iSlow5 = (1 + iSlow4);
	float fSlow6 = ((float)iSlow5 - fSlow3);
	float fSlow7 = (dsp->fConst3 / fSlow2);
	float fSlow8 = (dsp->fConst4 * fSlow2);
	float fSlow9 = (fSlow3 - (float)iSlow4);
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			dsp->iVec0[0] = 1;
			dsp->fRec1[0] = fmodf((dsp->fRec1[1] + fSlow8), 1.f);
			float fTemp0 = faustpower2_f(((2.f * dsp->fRec1[0]) - 1.f));
			dsp->fVec1[0] = fTemp0;
			float fTemp1 = (fSlow7 * ((fTemp0 - dsp->fVec1[1]) * (float)dsp->iVec0[1]));
			dsp->fVec2[(dsp->IOTA & 4095)] = fTemp1;
			dsp->fRec0[0] = (0.f - (((fSlow6 * dsp->fVec2[((dsp->IOTA - iSlow4) & 4095)]) + (fSlow9 * dsp->fVec2[((dsp->IOTA - iSlow5) & 4095)])) - ((0.999f * dsp->fRec0[1]) + fTemp1)));
			output0[i] = (FAUSTFLOAT)(fSlow1 * dsp->fRec0[0]);
			dsp->iVec0[1] = dsp->iVec0[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fVec1[1] = dsp->fVec1[0];
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec0[1] = dsp->fRec0[0];

		}

	}

}

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_bltriangle *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_bltriangle_create(sp_bltriangle **p)
{
    *p = malloc(sizeof(sp_bltriangle));
    return SP_OK;
}

int sp_bltriangle_destroy(sp_bltriangle **p)
{
    sp_bltriangle *pp = *p;
    bltriangle *dsp = pp->ud;
    deletebltriangle (dsp);
    free(*p);
    return SP_OK;
}

int sp_bltriangle_init(sp_data *sp, sp_bltriangle *p)
{
    bltriangle *dsp = newbltriangle(); UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfacebltriangle(dsp, &UI);
    initbltriangle(dsp, sp->sr);


    p->freq = p->args[0];
    p->amp = p->args[1];
    p->crest = p->args[2];

    p->ud = dsp;
    return SP_OK;
}

int sp_bltriangle_compute(sp_data *sp, sp_bltriangle *p, SPFLOAT *in, SPFLOAT *out)
{

    bltriangle *dsp = p->ud;
    SPFLOAT out1 = 0;
    SPFLOAT *faust_out[] = {&out1};
    SPFLOAT *faust_in[] = {in};
    computebltriangle(dsp, 1, faust_in, faust_out);

    *out = out1;
    return SP_OK;
}
