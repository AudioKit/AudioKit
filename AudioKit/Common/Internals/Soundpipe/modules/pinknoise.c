#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif  

typedef struct {
	float fRec0[4];
	int iRec1[2];
	FAUSTFLOAT fHslider0;
	int fSamplingFreq;
} pinknoise;

pinknoise* newpinknoise() { 
	pinknoise* dsp = (pinknoise*)malloc(sizeof(pinknoise));
	return dsp;
}

void deletepinknoise(pinknoise* dsp) { 
	free(dsp);
}

void instanceInitpinknoise(pinknoise* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->fHslider0 = (FAUSTFLOAT)1.;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 2); i0 = (i0 + 1)) {
			dsp->iRec1[i0] = 0;
			
		}
		
	}
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 4); i1 = (i1 + 1)) {
			dsp->fRec0[i1] = 0.f;
			
		}
		
	}
	
}

void initpinknoise(pinknoise* dsp, int samplingFreq) {
	instanceInitpinknoise(dsp, samplingFreq);
}

void buildUserInterfacepinknoise(pinknoise* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "amp", &dsp->fHslider0, 1.f, 0.f, 1.f, 0.0001f);
}

void computepinknoise(pinknoise* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* output0 = outputs[0];
	float fSlow0 = (float)dsp->fHslider0;
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			dsp->iRec1[0] = ((1103515245 * dsp->iRec1[1]) + 12345);
			dsp->fRec0[0] = (((0.522189f * dsp->fRec0[3]) + ((4.65661e-10f * (float)dsp->iRec1[0]) + (2.49496f * dsp->fRec0[1]))) - (2.01727f * dsp->fRec0[2]));
			output0[i] = (FAUSTFLOAT)(fSlow0 * (((0.049922f * dsp->fRec0[0]) + (0.0506127f * dsp->fRec0[2])) - ((0.0959935f * dsp->fRec0[1]) + (0.00440879f * dsp->fRec0[3]))));
			dsp->iRec1[1] = dsp->iRec1[0];
			/* C99 loop */
			{
				int j0;
				for (j0 = 3; (j0 > 0); j0 = (j0 - 1)) {
					dsp->fRec0[j0] = dsp->fRec0[(j0 - 1)];
					
				}
				
			}
			
		}
		
	}
	
}

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_pinknoise *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_pinknoise_create(sp_pinknoise **p)
{
    *p = malloc(sizeof(sp_pinknoise));
    return SP_OK;
}

int sp_pinknoise_destroy(sp_pinknoise **p)
{
    sp_pinknoise *pp = *p;
    pinknoise *dsp = pp->faust;
    deletepinknoise (dsp);
    free(*p);
    return SP_OK;
}

int sp_pinknoise_init(sp_data *sp, sp_pinknoise *p)
{
    pinknoise *dsp = newpinknoise(); 
    UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfacepinknoise(dsp, &UI);
    initpinknoise(dsp, sp->sr);
     
    p->amp = p->args[0];

    p->faust = dsp;
    return SP_OK;
}

int sp_pinknoise_compute(sp_data *sp, sp_pinknoise *p, SPFLOAT *in, SPFLOAT *out) 
{

    pinknoise *dsp = p->faust;
    SPFLOAT out1 = 0;
    SPFLOAT *faust_out[] = {&out1};
    SPFLOAT *faust_in[] = {in};
    computepinknoise(dsp, 1, faust_in, faust_out);

    /* quick fix to give this module the same overall amplitude as white noise */
    *out = out1 * 10.0; 
    return SP_OK;
}
