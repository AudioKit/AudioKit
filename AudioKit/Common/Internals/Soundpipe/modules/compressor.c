#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)


#ifndef FAUSTFLOAT
#define FAUSTFLOAT SPFLOAT
#endif  

typedef struct {
	float fRec2[2];
	float fRec1[2];
	float fRec0[2];
	int fSamplingFreq;
	int iConst0;
	float fConst1;
	FAUSTFLOAT fHslider0;
	FAUSTFLOAT fHslider1;
	float fConst2;
	FAUSTFLOAT fHslider2;
	FAUSTFLOAT fHslider3;
} compressor;

static compressor* newcompressor() { 
	compressor* dsp = (compressor*)malloc(sizeof(compressor));
	return dsp;
}

static void deletecompressor(compressor* dsp) { 
	free(dsp);
}

static void instanceInitcompressor(compressor* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->iConst0 = min(192000, max(1, dsp->fSamplingFreq));
	dsp->fConst1 = (2.f / (float)dsp->iConst0);
	dsp->fHslider0 = (FAUSTFLOAT)0.1;
	dsp->fHslider1 = (FAUSTFLOAT)1.;
	dsp->fConst2 = (1.f / (float)dsp->iConst0);
	dsp->fHslider2 = (FAUSTFLOAT)0.1;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 2); i0 = (i0 + 1)) {
			dsp->fRec2[i0] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec1[i1] = 0.f;
			
		}
		
	}
	dsp->fHslider3 = (FAUSTFLOAT)0.;
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 2); i2 = (i2 + 1)) {
			dsp->fRec0[i2] = 0.f;
			
		}
		
	}
	
}

static void initcompressor(compressor* dsp, int samplingFreq) {
	instanceInitcompressor(dsp, samplingFreq);
}

static void buildUserInterfacecompressor(compressor* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "ratio", &dsp->fHslider1, 1.f, 1.f, 40.f, 0.001f);
	interface->addHorizontalSlider(interface->uiInterface, "thresh", &dsp->fHslider3, 0.f, -80.f, 0.f, 0.001f);
	interface->addHorizontalSlider(interface->uiInterface, "atk", &dsp->fHslider0, 0.1f, 0.f, 10.f, 0.001f);
	interface->addHorizontalSlider(interface->uiInterface, "rel", &dsp->fHslider2, 0.1f, 0.f, 10.f, 0.001f);
}

static void computecompressor(compressor* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* output0 = outputs[0];
	float fSlow0 = (float)dsp->fHslider0;
	float fSlow1 = exp((0.f - (dsp->fConst1 / fSlow0)));
	float fSlow2 = ((1.f - fSlow1) * ((1.f / (float)dsp->fHslider1) - 1.f));
	float fSlow3 = exp((0.f - (dsp->fConst2 / fSlow0)));
	float fSlow4 = exp((0.f - (dsp->fConst2 / (float)dsp->fHslider2)));
	float fSlow5 = (float)dsp->fHslider3;
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			float fTemp0 = (float)input0[i];
			float fTemp1 = fabs(fTemp0);
			float fTemp2 = ((dsp->fRec1[1] > fTemp1)?fSlow4:fSlow3);
			dsp->fRec2[0] = ((dsp->fRec2[1] * fTemp2) + ((1.f - fTemp2) * fTemp1));
			dsp->fRec1[0] = dsp->fRec2[0];
			dsp->fRec0[0] = ((fSlow1 * dsp->fRec0[1]) + (fSlow2 * max(((20.f * log10(dsp->fRec1[0])) - fSlow5), 0.f)));
			output0[i] = (FAUSTFLOAT)(pow(10.f, (0.05f * dsp->fRec0[0])) * fTemp0);
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fRec0[1] = dsp->fRec0[0];
			
		}
		
	}
	
}

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_compressor *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_compressor_create(sp_compressor **p)
{
    *p = malloc(sizeof(sp_compressor));
    return SP_OK;
}

int sp_compressor_destroy(sp_compressor **p)
{
    sp_compressor *pp = *p;
    compressor *dsp = pp->faust;
    deletecompressor (dsp);
    free(*p);
    return SP_OK;
}

int sp_compressor_init(sp_data *sp, sp_compressor *p)
{
    compressor *dsp = newcompressor(); 
    UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfacecompressor(dsp, &UI);
    initcompressor(dsp, sp->sr);

     
    p->ratio = p->args[0]; 
    p->thresh = p->args[1]; 
    p->atk = p->args[2]; 
    p->rel = p->args[3];

    p->faust = dsp;
    return SP_OK;
}

int sp_compressor_compute(sp_data *sp, sp_compressor *p, SPFLOAT *in, SPFLOAT *out) 
{

    compressor *dsp = p->faust;
    SPFLOAT *faust_out[] = {out};
    SPFLOAT *faust_in[] = {in};
    computecompressor(dsp, 1, faust_in, faust_out);
    return SP_OK;
}
