/*
 * JCrev
 *
 * This code has been partially generated using Faust.
 * See the file "jcrev.dsp" to see the original faust code utilized. 
 *
 */

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

	float fVec5[4096];
	float fVec6[4096];
	float fVec3[2048];
	float fVec4[2048];
	float fVec0[512];
	float fVec1[128];
	float fVec2[64];
	float fRec6[2];
	float fRec4[2];
	float fRec2[2];
	float fRec0[2];
	float fRec1[2];
	float fRec8[2];
	float fRec9[2];
	float fRec10[2];
	float fRec11[2];
	float fRec12[2];
	float fRec13[2];
	int IOTA;
	int fSamplingFreq;

} jcrev;

jcrev* newjcrev() {
	jcrev* dsp = (jcrev*)malloc(sizeof(jcrev));
	return dsp;
}

void deletejcrev(jcrev* dsp) {
	free(dsp);
}

void instanceInitjcrev(jcrev* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 512); i0 = (i0 + 1)) {
			dsp->fVec0[i0] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec6[i1] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 128); i2 = (i2 + 1)) {
			dsp->fVec1[i2] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i3;
		for (i3 = 0; (i3 < 2); i3 = (i3 + 1)) {
			dsp->fRec4[i3] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i4;
		for (i4 = 0; (i4 < 64); i4 = (i4 + 1)) {
			dsp->fVec2[i4] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i5;
		for (i5 = 0; (i5 < 2); i5 = (i5 + 1)) {
			dsp->fRec2[i5] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i6;
		for (i6 = 0; (i6 < 2048); i6 = (i6 + 1)) {
			dsp->fVec3[i6] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i7;
		for (i7 = 0; (i7 < 2); i7 = (i7 + 1)) {
			dsp->fRec0[i7] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i8;
		for (i8 = 0; (i8 < 2); i8 = (i8 + 1)) {
			dsp->fRec1[i8] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i9;
		for (i9 = 0; (i9 < 2048); i9 = (i9 + 1)) {
			dsp->fVec4[i9] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i10;
		for (i10 = 0; (i10 < 2); i10 = (i10 + 1)) {
			dsp->fRec8[i10] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i11;
		for (i11 = 0; (i11 < 2); i11 = (i11 + 1)) {
			dsp->fRec9[i11] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i12;
		for (i12 = 0; (i12 < 4096); i12 = (i12 + 1)) {
			dsp->fVec5[i12] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i13;
		for (i13 = 0; (i13 < 2); i13 = (i13 + 1)) {
			dsp->fRec10[i13] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i14;
		for (i14 = 0; (i14 < 2); i14 = (i14 + 1)) {
			dsp->fRec11[i14] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i15;
		for (i15 = 0; (i15 < 4096); i15 = (i15 + 1)) {
			dsp->fVec6[i15] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i16;
		for (i16 = 0; (i16 < 2); i16 = (i16 + 1)) {
			dsp->fRec12[i16] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i17;
		for (i17 = 0; (i17 < 2); i17 = (i17 + 1)) {
			dsp->fRec13[i17] = 0.f;

		}

	}

}

void initjcrev(jcrev* dsp, int samplingFreq) {
	instanceInitjcrev(dsp, samplingFreq);
}

void computejcrev(jcrev* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* output0 = outputs[0];
	FAUSTFLOAT* output1 = outputs[1];
	FAUSTFLOAT* output2 = outputs[2];
	FAUSTFLOAT* output3 = outputs[3];
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			float fTemp0 = ((0.7f * dsp->fRec6[1]) + (0.06f * (float)input0[i]));
			dsp->fVec0[(dsp->IOTA & 511)] = fTemp0;
			dsp->fRec6[0] = dsp->fVec0[((dsp->IOTA - 346) & 511)];
			float fRec7 = (0.f - (0.7f * fTemp0));
			float fTemp1 = (dsp->fRec6[1] + (fRec7 + (0.7f * dsp->fRec4[1])));
			dsp->fVec1[(dsp->IOTA & 127)] = fTemp1;
			dsp->fRec4[0] = dsp->fVec1[((dsp->IOTA - 112) & 127)];
			float fRec5 = (0.f - (0.7f * fTemp1));
			float fTemp2 = (dsp->fRec4[1] + (fRec5 + (0.7f * dsp->fRec2[1])));
			dsp->fVec2[(dsp->IOTA & 63)] = fTemp2;
			dsp->fRec2[0] = dsp->fVec2[((dsp->IOTA - 36) & 63)];
			float fRec3 = (0.f - (0.7f * fTemp2));
			float fTemp3 = (dsp->fRec2[1] + (fRec3 + (0.802f * dsp->fRec0[1])));
			dsp->fVec3[(dsp->IOTA & 2047)] = fTemp3;
			dsp->fRec0[0] = dsp->fVec3[((dsp->IOTA - 1600) & 2047)];
			dsp->fRec1[0] = fTemp3;
			float fTemp4 = (fRec3 + dsp->fRec2[1]);
			float fTemp5 = (fTemp4 + (0.773f * dsp->fRec8[1]));
			dsp->fVec4[(dsp->IOTA & 2047)] = fTemp5;
			dsp->fRec8[0] = dsp->fVec4[((dsp->IOTA - 1866) & 2047)];
			dsp->fRec9[0] = fTemp5;
			float fTemp6 = (fTemp4 + (0.753f * dsp->fRec10[1]));
			dsp->fVec5[(dsp->IOTA & 4095)] = fTemp6;
			dsp->fRec10[0] = dsp->fVec5[((dsp->IOTA - 2052) & 4095)];
			dsp->fRec11[0] = fTemp6;
			float fTemp7 = (fTemp4 + (0.733f * dsp->fRec12[1]));
			dsp->fVec6[(dsp->IOTA & 4095)] = fTemp7;
			dsp->fRec12[0] = dsp->fVec6[((dsp->IOTA - 2250) & 4095)];
			dsp->fRec13[0] = fTemp7;
			float fTemp8 = (((dsp->fRec1[1] + dsp->fRec9[1]) + dsp->fRec11[1]) + dsp->fRec13[1]);
			output0[i] = (FAUSTFLOAT)fTemp8;
			output1[i] = (FAUSTFLOAT)(0.f - fTemp8);
			float fTemp9 = (dsp->fRec1[1] + dsp->fRec11[1]);
			float fTemp10 = (dsp->fRec9[1] + dsp->fRec13[1]);
			output2[i] = (FAUSTFLOAT)(0.f - (fTemp9 - fTemp10));
			output3[i] = (FAUSTFLOAT)(0.f - (fTemp10 - fTemp9));
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec6[1] = dsp->fRec6[0];
			dsp->fRec4[1] = dsp->fRec4[0];
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fRec8[1] = dsp->fRec8[0];
			dsp->fRec9[1] = dsp->fRec9[0];
			dsp->fRec10[1] = dsp->fRec10[0];
			dsp->fRec11[1] = dsp->fRec11[0];
			dsp->fRec12[1] = dsp->fRec12[0];
			dsp->fRec13[1] = dsp->fRec13[0];

		}

	}

}


int sp_jcrev_create(sp_jcrev **p)
{
    *p = malloc(sizeof(sp_jcrev));
    return SP_OK;
}

int sp_jcrev_destroy(sp_jcrev **p)
{
    sp_jcrev *pp = *p;
    jcrev *dsp = pp->ud;
    deletejcrev(dsp);
    free(*p);
    return SP_OK;
}

int sp_jcrev_init(sp_data *sp, sp_jcrev *p)
{
    jcrev *dsp = newjcrev();
    initjcrev(dsp, sp->sr);
    p->ud = dsp;
    return SP_OK;
}

int sp_jcrev_compute(sp_data *sp, sp_jcrev *p, SPFLOAT *in, SPFLOAT *out)
{

    jcrev *dsp = p->ud;
    SPFLOAT out1 = 0, out2 = 0, out3 = 0, out4 = 0;
    SPFLOAT *faust_out[] = {&out1, &out2, &out3, &out4};
    computejcrev(dsp, 1, &in, faust_out);

    /* As you can see, only 1 out of the 4 channels are being used */
    *out = out1;
    return SP_OK;
}
