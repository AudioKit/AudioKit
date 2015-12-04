/* ------------------------------------------------------------
Code generated with Faust 2.0.a37 (http://faust.grame.fr)
------------------------------------------------------------ */

#ifndef  __zitarev_H__
#define  __zitarev_H__
#include <math.h>
#include "soundpipe.h"
#include "CUI.h"
#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)


#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#include <math.h>

float powf(float dummy0, float dummy1);
float sqrtf(float dummy0);
float cosf(float dummy0);
float floorf(float dummy0);
float expf(float dummy0);
static float faustpower2_f(float value) {
	return (value * value);

}

float tanf(float dummy0);

typedef struct {

	float fVec0[16384];
	float fVec3[16384];
	float fVec7[16384];
	float fVec1[8192];
	float fVec5[8192];
	float fVec9[8192];
	float fVec10[8192];
	float fVec12[8192];
	float fVec14[8192];
	float fVec16[8192];
	float fVec4[2048];
	float fVec6[2048];
	float fVec8[2048];
	float fVec13[2048];
	float fVec15[2048];
	float fVec2[1024];
	float fVec11[1024];
	float fVec17[1024];
	float fRec3[3];
	float fRec4[3];
	float fRec5[3];
	float fRec6[3];
	float fRec7[3];
	float fRec8[3];
	float fRec9[3];
	float fRec10[3];
	float fRec2[3];
	float fRec1[3];
	float fRec45[3];
	float fRec44[3];
	float fRec0[2];
	float fRec14[2];
	float fRec13[2];
	float fRec11[2];
	float fRec18[2];
	float fRec17[2];
	float fRec15[2];
	float fRec22[2];
	float fRec21[2];
	float fRec19[2];
	float fRec26[2];
	float fRec25[2];
	float fRec23[2];
	float fRec30[2];
	float fRec29[2];
	float fRec27[2];
	float fRec34[2];
	float fRec33[2];
	float fRec31[2];
	float fRec38[2];
	float fRec37[2];
	float fRec35[2];
	float fRec42[2];
	float fRec41[2];
	float fRec39[2];
	float fRec43[2];
	FAUSTFLOAT fHslider0;
	int fSamplingFreq;
	int iConst0;
	float fConst1;
	FAUSTFLOAT fHslider1;
	FAUSTFLOAT fHslider2;
	FAUSTFLOAT fHslider3;
	FAUSTFLOAT fHslider4;
	float fConst2;
	float fConst3;
	FAUSTFLOAT fHslider5;
	float fConst4;
	FAUSTFLOAT fHslider6;
	FAUSTFLOAT fHslider7;
	float fConst5;
	FAUSTFLOAT fHslider8;
	int IOTA;
	float fConst6;
	int iConst7;
	float fConst8;
	FAUSTFLOAT fHslider9;
	int iConst9;
	float fConst10;
	float fConst11;
	float fConst12;
	int iConst13;
	int iConst14;
	float fConst15;
	float fConst16;
	float fConst17;
	int iConst18;
	int iConst19;
	float fConst20;
	float fConst21;
	float fConst22;
	int iConst23;
	int iConst24;
	float fConst25;
	float fConst26;
	float fConst27;
	int iConst28;
	int iConst29;
	float fConst30;
	float fConst31;
	float fConst32;
	int iConst33;
	int iConst34;
	float fConst35;
	float fConst36;
	float fConst37;
	int iConst38;
	int iConst39;
	float fConst40;
	float fConst41;
	float fConst42;
	int iConst43;
	int iConst44;
	FAUSTFLOAT fHslider10;

} zitarev;

zitarev* newzitarev() {
	zitarev* dsp = (zitarev*)malloc(sizeof(zitarev));
	return dsp;
}

static void deletezitarev(zitarev* dsp) {
	free(dsp);
}

static void instanceInitzitarev(zitarev* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->fHslider0 = (FAUSTFLOAT)-20.;
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 2); i0 = (i0 + 1)) {
			dsp->fRec0[i0] = 0.f;

		}

	}
	dsp->iConst0 = min(192000, max(1, dsp->fSamplingFreq));
	dsp->fConst1 = (6.28319f / (float)dsp->iConst0);
	dsp->fHslider1 = (FAUSTFLOAT)1500.;
	dsp->fHslider2 = (FAUSTFLOAT)0.;
	dsp->fHslider3 = (FAUSTFLOAT)315.;
	dsp->fHslider4 = (FAUSTFLOAT)0.;
	dsp->fConst2 = floorf((0.5f + (0.219991f * (float)dsp->iConst0)));
	dsp->fConst3 = ((0.f - (6.90776f * dsp->fConst2)) / (float)dsp->iConst0);
	dsp->fHslider5 = (FAUSTFLOAT)2.;
	dsp->fConst4 = (6.28319f / (float)dsp->iConst0);
	dsp->fHslider6 = (FAUSTFLOAT)6000.;
	dsp->fHslider7 = (FAUSTFLOAT)3.;
	dsp->fConst5 = (3.14159f / (float)dsp->iConst0);
	dsp->fHslider8 = (FAUSTFLOAT)200.;
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec14[i1] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 2); i2 = (i2 + 1)) {
			dsp->fRec13[i2] = 0.f;

		}

	}
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int i3;
		for (i3 = 0; (i3 < 16384); i3 = (i3 + 1)) {
			dsp->fVec0[i3] = 0.f;

		}

	}
	dsp->fConst6 = floorf((0.5f + (0.019123f * (float)dsp->iConst0)));
	dsp->iConst7 = (int)((int)(dsp->fConst2 - dsp->fConst6) & 16383);
	/* C99 loop */
	{
		int i4;
		for (i4 = 0; (i4 < 8192); i4 = (i4 + 1)) {
			dsp->fVec1[i4] = 0.f;

		}

	}
	dsp->fConst8 = (0.001f * (float)dsp->iConst0);
	dsp->fHslider9 = (FAUSTFLOAT)60.;
	/* C99 loop */
	{
		int i5;
		for (i5 = 0; (i5 < 1024); i5 = (i5 + 1)) {
			dsp->fVec2[i5] = 0.f;

		}

	}
	dsp->iConst9 = (int)((int)(dsp->fConst6 - 1.f) & 1023);
	/* C99 loop */
	{
		int i6;
		for (i6 = 0; (i6 < 2); i6 = (i6 + 1)) {
			dsp->fRec11[i6] = 0.f;

		}

	}
	dsp->fConst10 = floorf((0.5f + (0.256891f * (float)dsp->iConst0)));
	dsp->fConst11 = ((0.f - (6.90776f * dsp->fConst10)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i7;
		for (i7 = 0; (i7 < 2); i7 = (i7 + 1)) {
			dsp->fRec18[i7] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i8;
		for (i8 = 0; (i8 < 2); i8 = (i8 + 1)) {
			dsp->fRec17[i8] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i9;
		for (i9 = 0; (i9 < 16384); i9 = (i9 + 1)) {
			dsp->fVec3[i9] = 0.f;

		}

	}
	dsp->fConst12 = floorf((0.5f + (0.027333f * (float)dsp->iConst0)));
	dsp->iConst13 = (int)((int)(dsp->fConst10 - dsp->fConst12) & 16383);
	/* C99 loop */
	{
		int i10;
		for (i10 = 0; (i10 < 2048); i10 = (i10 + 1)) {
			dsp->fVec4[i10] = 0.f;

		}

	}
	dsp->iConst14 = (int)((int)(dsp->fConst12 - 1.f) & 2047);
	/* C99 loop */
	{
		int i11;
		for (i11 = 0; (i11 < 2); i11 = (i11 + 1)) {
			dsp->fRec15[i11] = 0.f;

		}

	}
	dsp->fConst15 = floorf((0.5f + (0.192303f * (float)dsp->iConst0)));
	dsp->fConst16 = ((0.f - (6.90776f * dsp->fConst15)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i12;
		for (i12 = 0; (i12 < 2); i12 = (i12 + 1)) {
			dsp->fRec22[i12] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i13;
		for (i13 = 0; (i13 < 2); i13 = (i13 + 1)) {
			dsp->fRec21[i13] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i14;
		for (i14 = 0; (i14 < 8192); i14 = (i14 + 1)) {
			dsp->fVec5[i14] = 0.f;

		}

	}
	dsp->fConst17 = floorf((0.5f + (0.029291f * (float)dsp->iConst0)));
	dsp->iConst18 = (int)((int)(dsp->fConst15 - dsp->fConst17) & 8191);
	/* C99 loop */
	{
		int i15;
		for (i15 = 0; (i15 < 2048); i15 = (i15 + 1)) {
			dsp->fVec6[i15] = 0.f;

		}

	}
	dsp->iConst19 = (int)((int)(dsp->fConst17 - 1.f) & 2047);
	/* C99 loop */
	{
		int i16;
		for (i16 = 0; (i16 < 2); i16 = (i16 + 1)) {
			dsp->fRec19[i16] = 0.f;

		}

	}
	dsp->fConst20 = floorf((0.5f + (0.210389f * (float)dsp->iConst0)));
	dsp->fConst21 = ((0.f - (6.90776f * dsp->fConst20)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i17;
		for (i17 = 0; (i17 < 2); i17 = (i17 + 1)) {
			dsp->fRec26[i17] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i18;
		for (i18 = 0; (i18 < 2); i18 = (i18 + 1)) {
			dsp->fRec25[i18] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i19;
		for (i19 = 0; (i19 < 16384); i19 = (i19 + 1)) {
			dsp->fVec7[i19] = 0.f;

		}

	}
	dsp->fConst22 = floorf((0.5f + (0.024421f * (float)dsp->iConst0)));
	dsp->iConst23 = (int)((int)(dsp->fConst20 - dsp->fConst22) & 16383);
	/* C99 loop */
	{
		int i20;
		for (i20 = 0; (i20 < 2048); i20 = (i20 + 1)) {
			dsp->fVec8[i20] = 0.f;

		}

	}
	dsp->iConst24 = (int)((int)(dsp->fConst22 - 1.f) & 2047);
	/* C99 loop */
	{
		int i21;
		for (i21 = 0; (i21 < 2); i21 = (i21 + 1)) {
			dsp->fRec23[i21] = 0.f;

		}

	}
	dsp->fConst25 = floorf((0.5f + (0.125f * (float)dsp->iConst0)));
	dsp->fConst26 = ((0.f - (6.90776f * dsp->fConst25)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i22;
		for (i22 = 0; (i22 < 2); i22 = (i22 + 1)) {
			dsp->fRec30[i22] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i23;
		for (i23 = 0; (i23 < 2); i23 = (i23 + 1)) {
			dsp->fRec29[i23] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i24;
		for (i24 = 0; (i24 < 8192); i24 = (i24 + 1)) {
			dsp->fVec9[i24] = 0.f;

		}

	}
	dsp->fConst27 = floorf((0.5f + (0.013458f * (float)dsp->iConst0)));
	dsp->iConst28 = (int)((int)(dsp->fConst25 - dsp->fConst27) & 8191);
	/* C99 loop */
	{
		int i25;
		for (i25 = 0; (i25 < 8192); i25 = (i25 + 1)) {
			dsp->fVec10[i25] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i26;
		for (i26 = 0; (i26 < 1024); i26 = (i26 + 1)) {
			dsp->fVec11[i26] = 0.f;

		}

	}
	dsp->iConst29 = (int)((int)(dsp->fConst27 - 1.f) & 1023);
	/* C99 loop */
	{
		int i27;
		for (i27 = 0; (i27 < 2); i27 = (i27 + 1)) {
			dsp->fRec27[i27] = 0.f;

		}

	}
	dsp->fConst30 = floorf((0.5f + (0.127837f * (float)dsp->iConst0)));
	dsp->fConst31 = ((0.f - (6.90776f * dsp->fConst30)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i28;
		for (i28 = 0; (i28 < 2); i28 = (i28 + 1)) {
			dsp->fRec34[i28] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i29;
		for (i29 = 0; (i29 < 2); i29 = (i29 + 1)) {
			dsp->fRec33[i29] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i30;
		for (i30 = 0; (i30 < 8192); i30 = (i30 + 1)) {
			dsp->fVec12[i30] = 0.f;

		}

	}
	dsp->fConst32 = floorf((0.5f + (0.031604f * (float)dsp->iConst0)));
	dsp->iConst33 = (int)((int)(dsp->fConst30 - dsp->fConst32) & 8191);
	/* C99 loop */
	{
		int i31;
		for (i31 = 0; (i31 < 2048); i31 = (i31 + 1)) {
			dsp->fVec13[i31] = 0.f;

		}

	}
	dsp->iConst34 = (int)((int)(dsp->fConst32 - 1.f) & 2047);
	/* C99 loop */
	{
		int i32;
		for (i32 = 0; (i32 < 2); i32 = (i32 + 1)) {
			dsp->fRec31[i32] = 0.f;

		}

	}
	dsp->fConst35 = floorf((0.5f + (0.174713f * (float)dsp->iConst0)));
	dsp->fConst36 = ((0.f - (6.90776f * dsp->fConst35)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i33;
		for (i33 = 0; (i33 < 2); i33 = (i33 + 1)) {
			dsp->fRec38[i33] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i34;
		for (i34 = 0; (i34 < 2); i34 = (i34 + 1)) {
			dsp->fRec37[i34] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i35;
		for (i35 = 0; (i35 < 8192); i35 = (i35 + 1)) {
			dsp->fVec14[i35] = 0.f;

		}

	}
	dsp->fConst37 = floorf((0.5f + (0.022904f * (float)dsp->iConst0)));
	dsp->iConst38 = (int)((int)(dsp->fConst35 - dsp->fConst37) & 8191);
	/* C99 loop */
	{
		int i36;
		for (i36 = 0; (i36 < 2048); i36 = (i36 + 1)) {
			dsp->fVec15[i36] = 0.f;

		}

	}
	dsp->iConst39 = (int)((int)(dsp->fConst37 - 1.f) & 2047);
	/* C99 loop */
	{
		int i37;
		for (i37 = 0; (i37 < 2); i37 = (i37 + 1)) {
			dsp->fRec35[i37] = 0.f;

		}

	}
	dsp->fConst40 = floorf((0.5f + (0.153129f * (float)dsp->iConst0)));
	dsp->fConst41 = ((0.f - (6.90776f * dsp->fConst40)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i38;
		for (i38 = 0; (i38 < 2); i38 = (i38 + 1)) {
			dsp->fRec42[i38] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i39;
		for (i39 = 0; (i39 < 2); i39 = (i39 + 1)) {
			dsp->fRec41[i39] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i40;
		for (i40 = 0; (i40 < 8192); i40 = (i40 + 1)) {
			dsp->fVec16[i40] = 0.f;

		}

	}
	dsp->fConst42 = floorf((0.5f + (0.020346f * (float)dsp->iConst0)));
	dsp->iConst43 = (int)((int)(dsp->fConst40 - dsp->fConst42) & 8191);
	/* C99 loop */
	{
		int i41;
		for (i41 = 0; (i41 < 1024); i41 = (i41 + 1)) {
			dsp->fVec17[i41] = 0.f;

		}

	}
	dsp->iConst44 = (int)((int)(dsp->fConst42 - 1.f) & 1023);
	/* C99 loop */
	{
		int i42;
		for (i42 = 0; (i42 < 2); i42 = (i42 + 1)) {
			dsp->fRec39[i42] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i43;
		for (i43 = 0; (i43 < 3); i43 = (i43 + 1)) {
			dsp->fRec3[i43] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i44;
		for (i44 = 0; (i44 < 3); i44 = (i44 + 1)) {
			dsp->fRec4[i44] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i45;
		for (i45 = 0; (i45 < 3); i45 = (i45 + 1)) {
			dsp->fRec5[i45] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i46;
		for (i46 = 0; (i46 < 3); i46 = (i46 + 1)) {
			dsp->fRec6[i46] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i47;
		for (i47 = 0; (i47 < 3); i47 = (i47 + 1)) {
			dsp->fRec7[i47] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i48;
		for (i48 = 0; (i48 < 3); i48 = (i48 + 1)) {
			dsp->fRec8[i48] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i49;
		for (i49 = 0; (i49 < 3); i49 = (i49 + 1)) {
			dsp->fRec9[i49] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i50;
		for (i50 = 0; (i50 < 3); i50 = (i50 + 1)) {
			dsp->fRec10[i50] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i51;
		for (i51 = 0; (i51 < 3); i51 = (i51 + 1)) {
			dsp->fRec2[i51] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i52;
		for (i52 = 0; (i52 < 3); i52 = (i52 + 1)) {
			dsp->fRec1[i52] = 0.f;

		}

	}
	dsp->fHslider10 = (FAUSTFLOAT)0.;
	/* C99 loop */
	{
		int i53;
		for (i53 = 0; (i53 < 2); i53 = (i53 + 1)) {
			dsp->fRec43[i53] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i54;
		for (i54 = 0; (i54 < 3); i54 = (i54 + 1)) {
			dsp->fRec45[i54] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i55;
		for (i55 = 0; (i55 < 3); i55 = (i55 + 1)) {
			dsp->fRec44[i55] = 0.f;

		}

	}

}

static void initzitarev(zitarev* dsp, int samplingFreq) {
	instanceInitzitarev(dsp, samplingFreq);
}

static void buildUserInterfacezitarev(zitarev* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "In Delay", &dsp->fHslider9, 60.f, 20.f, 100.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "LF X", &dsp->fHslider8, 200.f, 50.f, 1000.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "Low RT60", &dsp->fHslider7, 3.f, 1.f, 8.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "Mid RT60", &dsp->fHslider5, 2.f, 1.f, 8.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "HF Damping", &dsp->fHslider6, 6000.f, 1500.f, 23520.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "Eq1 Freq", &dsp->fHslider3, 315.f, 40.f, 2500.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "Eq1 Level", &dsp->fHslider4, 0.f, -15.f, 15.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "Eq2 Freq", &dsp->fHslider1, 1500.f, 160.f, 10000.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "Eq2 Level", &dsp->fHslider2, 0.f, -15.f, 15.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "Dry/Wet Mix", &dsp->fHslider10, 0.f, -1.f, 1.f, 0.01f);
	interface->addHorizontalSlider(interface->uiInterface, "Level", &dsp->fHslider0, -20.f, -70.f, 40.f, 0.1f);
}

static void computezitarev(zitarev* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* input1 = inputs[1];
	FAUSTFLOAT* output0 = outputs[0];
	FAUSTFLOAT* output1 = outputs[1];
	float fSlow0 = (0.001f * powf(10.f, (0.05f * (float)dsp->fHslider0)));
	float fSlow1 = (float)dsp->fHslider1;
	float fSlow2 = powf(10.f, (0.05f * (float)dsp->fHslider2));
	float fSlow3 = (dsp->fConst1 * (fSlow1 / sqrtf(max(0.f, fSlow2))));
	float fSlow4 = ((1.f - fSlow3) / (1.f + fSlow3));
	float fSlow5 = ((0.f - cosf((dsp->fConst1 * fSlow1))) * (1.f + fSlow4));
	float fSlow6 = (float)dsp->fHslider3;
	float fSlow7 = powf(10.f, (0.05f * (float)dsp->fHslider4));
	float fSlow8 = (dsp->fConst1 * (fSlow6 / sqrtf(max(0.f, fSlow7))));
	float fSlow9 = ((1.f - fSlow8) / (1.f + fSlow8));
	float fSlow10 = ((0.f - cosf((dsp->fConst1 * fSlow6))) * (1.f + fSlow9));
	float fSlow11 = (float)dsp->fHslider5;
	float fSlow12 = expf((dsp->fConst3 / fSlow11));
	float fSlow13 = faustpower2_f(fSlow12);
	float fSlow14 = cosf((dsp->fConst4 * (float)dsp->fHslider6));
	float fSlow15 = (1.f - (fSlow13 * fSlow14));
	float fSlow16 = (1.f - fSlow13);
	float fSlow17 = (fSlow15 / fSlow16);
	float fSlow18 = sqrtf(max(0.f, ((faustpower2_f(fSlow15) / faustpower2_f(fSlow16)) - 1.f)));
	float fSlow19 = (fSlow17 - fSlow18);
	float fSlow20 = (((1.f + fSlow18) - fSlow17) * fSlow12);
	float fSlow21 = (float)dsp->fHslider7;
	float fSlow22 = ((expf((dsp->fConst3 / fSlow21)) / fSlow12) - 1.f);
	float fSlow23 = (1.f / tanf((dsp->fConst5 * (float)dsp->fHslider8)));
	float fSlow24 = (1.f + fSlow23);
	float fSlow25 = (0.f - ((1.f - fSlow23) / fSlow24));
	float fSlow26 = (1.f / fSlow24);
	int iSlow27 = (int)((int)(dsp->fConst8 * (float)dsp->fHslider9) & 8191);
	float fSlow28 = expf((dsp->fConst11 / fSlow11));
	float fSlow29 = faustpower2_f(fSlow28);
	float fSlow30 = (1.f - (fSlow14 * fSlow29));
	float fSlow31 = (1.f - fSlow29);
	float fSlow32 = (fSlow30 / fSlow31);
	float fSlow33 = sqrtf(max(0.f, ((faustpower2_f(fSlow30) / faustpower2_f(fSlow31)) - 1.f)));
	float fSlow34 = (fSlow32 - fSlow33);
	float fSlow35 = (((1.f + fSlow33) - fSlow32) * fSlow28);
	float fSlow36 = ((expf((dsp->fConst11 / fSlow21)) / fSlow28) - 1.f);
	float fSlow37 = expf((dsp->fConst16 / fSlow11));
	float fSlow38 = faustpower2_f(fSlow37);
	float fSlow39 = (1.f - (fSlow14 * fSlow38));
	float fSlow40 = (1.f - fSlow38);
	float fSlow41 = (fSlow39 / fSlow40);
	float fSlow42 = sqrtf(max(0.f, ((faustpower2_f(fSlow39) / faustpower2_f(fSlow40)) - 1.f)));
	float fSlow43 = (fSlow41 - fSlow42);
	float fSlow44 = (((1.f + fSlow42) - fSlow41) * fSlow37);
	float fSlow45 = ((expf((dsp->fConst16 / fSlow21)) / fSlow37) - 1.f);
	float fSlow46 = expf((dsp->fConst21 / fSlow11));
	float fSlow47 = faustpower2_f(fSlow46);
	float fSlow48 = (1.f - (fSlow14 * fSlow47));
	float fSlow49 = (1.f - fSlow47);
	float fSlow50 = (fSlow48 / fSlow49);
	float fSlow51 = sqrtf(max(0.f, ((faustpower2_f(fSlow48) / faustpower2_f(fSlow49)) - 1.f)));
	float fSlow52 = (fSlow50 - fSlow51);
	float fSlow53 = (((1.f + fSlow51) - fSlow50) * fSlow46);
	float fSlow54 = ((expf((dsp->fConst21 / fSlow21)) / fSlow46) - 1.f);
	float fSlow55 = expf((dsp->fConst26 / fSlow11));
	float fSlow56 = faustpower2_f(fSlow55);
	float fSlow57 = (1.f - (fSlow14 * fSlow56));
	float fSlow58 = (1.f - fSlow56);
	float fSlow59 = (fSlow57 / fSlow58);
	float fSlow60 = sqrtf(max(0.f, ((faustpower2_f(fSlow57) / faustpower2_f(fSlow58)) - 1.f)));
	float fSlow61 = (fSlow59 - fSlow60);
	float fSlow62 = (((1.f + fSlow60) - fSlow59) * fSlow55);
	float fSlow63 = ((expf((dsp->fConst26 / fSlow21)) / fSlow55) - 1.f);
	float fSlow64 = expf((dsp->fConst31 / fSlow11));
	float fSlow65 = faustpower2_f(fSlow64);
	float fSlow66 = (1.f - (fSlow14 * fSlow65));
	float fSlow67 = (1.f - fSlow65);
	float fSlow68 = (fSlow66 / fSlow67);
	float fSlow69 = sqrtf(max(0.f, ((faustpower2_f(fSlow66) / faustpower2_f(fSlow67)) - 1.f)));
	float fSlow70 = (fSlow68 - fSlow69);
	float fSlow71 = (((1.f + fSlow69) - fSlow68) * fSlow64);
	float fSlow72 = ((expf((dsp->fConst31 / fSlow21)) / fSlow64) - 1.f);
	float fSlow73 = expf((dsp->fConst36 / fSlow11));
	float fSlow74 = faustpower2_f(fSlow73);
	float fSlow75 = (1.f - (fSlow14 * fSlow74));
	float fSlow76 = (1.f - fSlow74);
	float fSlow77 = (fSlow75 / fSlow76);
	float fSlow78 = sqrtf(max(0.f, ((faustpower2_f(fSlow75) / faustpower2_f(fSlow76)) - 1.f)));
	float fSlow79 = (fSlow77 - fSlow78);
	float fSlow80 = (((1.f + fSlow78) - fSlow77) * fSlow73);
	float fSlow81 = ((expf((dsp->fConst36 / fSlow21)) / fSlow73) - 1.f);
	float fSlow82 = expf((dsp->fConst41 / fSlow11));
	float fSlow83 = faustpower2_f(fSlow82);
	float fSlow84 = (1.f - (fSlow83 * fSlow14));
	float fSlow85 = (1.f - fSlow83);
	float fSlow86 = (fSlow84 / fSlow85);
	float fSlow87 = sqrtf(max(0.f, ((faustpower2_f(fSlow84) / faustpower2_f(fSlow85)) - 1.f)));
	float fSlow88 = (fSlow86 - fSlow87);
	float fSlow89 = (((1.f + fSlow87) - fSlow86) * fSlow82);
	float fSlow90 = ((expf((dsp->fConst41 / fSlow21)) / fSlow82) - 1.f);
	float fSlow91 = (0.001f * (float)dsp->fHslider10);
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			dsp->fRec0[0] = ((0.999f * dsp->fRec0[1]) + fSlow0);
			float fTemp0 = (fSlow5 * dsp->fRec1[1]);
			float fTemp1 = (fSlow10 * dsp->fRec2[1]);
			dsp->fRec14[0] = ((fSlow25 * dsp->fRec14[1]) + (fSlow26 * (dsp->fRec10[1] + dsp->fRec10[2])));
			dsp->fRec13[0] = ((fSlow19 * dsp->fRec13[1]) + (fSlow20 * (dsp->fRec10[1] + (fSlow22 * dsp->fRec14[0]))));
			dsp->fVec0[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec13[0]) + 1e-20f);
			float fTemp2 = (float)input1[i];
			dsp->fVec1[(dsp->IOTA & 8191)] = fTemp2;
			float fTemp3 = (0.3f * dsp->fVec1[((dsp->IOTA - iSlow27) & 8191)]);
			float fTemp4 = (((0.6f * dsp->fRec11[1]) + dsp->fVec0[((dsp->IOTA - dsp->iConst7) & 16383)]) - fTemp3);
			dsp->fVec2[(dsp->IOTA & 1023)] = fTemp4;
			dsp->fRec11[0] = dsp->fVec2[((dsp->IOTA - dsp->iConst9) & 1023)];
			float fRec12 = (0.f - (0.6f * fTemp4));
			dsp->fRec18[0] = ((fSlow25 * dsp->fRec18[1]) + (fSlow26 * (dsp->fRec6[1] + dsp->fRec6[2])));
			dsp->fRec17[0] = ((fSlow34 * dsp->fRec17[1]) + (fSlow35 * (dsp->fRec6[1] + (fSlow36 * dsp->fRec18[0]))));
			dsp->fVec3[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec17[0]) + 1e-20f);
			float fTemp5 = (((0.6f * dsp->fRec15[1]) + dsp->fVec3[((dsp->IOTA - dsp->iConst13) & 16383)]) - fTemp3);
			dsp->fVec4[(dsp->IOTA & 2047)] = fTemp5;
			dsp->fRec15[0] = dsp->fVec4[((dsp->IOTA - dsp->iConst14) & 2047)];
			float fRec16 = (0.f - (0.6f * fTemp5));
			dsp->fRec22[0] = ((fSlow25 * dsp->fRec22[1]) + (fSlow26 * (dsp->fRec8[1] + dsp->fRec8[2])));
			dsp->fRec21[0] = ((fSlow43 * dsp->fRec21[1]) + (fSlow44 * (dsp->fRec8[1] + (fSlow45 * dsp->fRec22[0]))));
			dsp->fVec5[(dsp->IOTA & 8191)] = ((0.353553f * dsp->fRec21[0]) + 1e-20f);
			float fTemp6 = (dsp->fVec5[((dsp->IOTA - dsp->iConst18) & 8191)] + (fTemp3 + (0.6f * dsp->fRec19[1])));
			dsp->fVec6[(dsp->IOTA & 2047)] = fTemp6;
			dsp->fRec19[0] = dsp->fVec6[((dsp->IOTA - dsp->iConst19) & 2047)];
			float fRec20 = (0.f - (0.6f * fTemp6));
			dsp->fRec26[0] = ((fSlow25 * dsp->fRec26[1]) + (fSlow26 * (dsp->fRec4[1] + dsp->fRec4[2])));
			dsp->fRec25[0] = ((fSlow52 * dsp->fRec25[1]) + (fSlow53 * (dsp->fRec4[1] + (fSlow54 * dsp->fRec26[0]))));
			dsp->fVec7[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec25[0]) + 1e-20f);
			float fTemp7 = (fTemp3 + ((0.6f * dsp->fRec23[1]) + dsp->fVec7[((dsp->IOTA - dsp->iConst23) & 16383)]));
			dsp->fVec8[(dsp->IOTA & 2047)] = fTemp7;
			dsp->fRec23[0] = dsp->fVec8[((dsp->IOTA - dsp->iConst24) & 2047)];
			float fRec24 = (0.f - (0.6f * fTemp7));
			dsp->fRec30[0] = ((fSlow25 * dsp->fRec30[1]) + (fSlow26 * (dsp->fRec9[1] + dsp->fRec9[2])));
			dsp->fRec29[0] = ((fSlow61 * dsp->fRec29[1]) + (fSlow62 * (dsp->fRec9[1] + (fSlow63 * dsp->fRec30[0]))));
			dsp->fVec9[(dsp->IOTA & 8191)] = ((0.353553f * dsp->fRec29[0]) + 1e-20f);
			float fTemp8 = (float)input0[i];
			dsp->fVec10[(dsp->IOTA & 8191)] = fTemp8;
			float fTemp9 = (0.3f * dsp->fVec10[((dsp->IOTA - iSlow27) & 8191)]);
			float fTemp10 = (dsp->fVec9[((dsp->IOTA - dsp->iConst28) & 8191)] - (fTemp9 + (0.6f * dsp->fRec27[1])));
			dsp->fVec11[(dsp->IOTA & 1023)] = fTemp10;
			dsp->fRec27[0] = dsp->fVec11[((dsp->IOTA - dsp->iConst29) & 1023)];
			float fRec28 = (0.6f * fTemp10);
			dsp->fRec34[0] = ((fSlow25 * dsp->fRec34[1]) + (fSlow26 * (dsp->fRec5[1] + dsp->fRec5[2])));
			dsp->fRec33[0] = ((fSlow70 * dsp->fRec33[1]) + (fSlow71 * (dsp->fRec5[1] + (fSlow72 * dsp->fRec34[0]))));
			dsp->fVec12[(dsp->IOTA & 8191)] = ((0.353553f * dsp->fRec33[0]) + 1e-20f);
			float fTemp11 = (dsp->fVec12[((dsp->IOTA - dsp->iConst33) & 8191)] - (fTemp9 + (0.6f * dsp->fRec31[1])));
			dsp->fVec13[(dsp->IOTA & 2047)] = fTemp11;
			dsp->fRec31[0] = dsp->fVec13[((dsp->IOTA - dsp->iConst34) & 2047)];
			float fRec32 = (0.6f * fTemp11);
			dsp->fRec38[0] = ((fSlow25 * dsp->fRec38[1]) + (fSlow26 * (dsp->fRec7[1] + dsp->fRec7[2])));
			dsp->fRec37[0] = ((fSlow79 * dsp->fRec37[1]) + (fSlow80 * (dsp->fRec7[1] + (fSlow81 * dsp->fRec38[0]))));
			dsp->fVec14[(dsp->IOTA & 8191)] = ((0.353553f * dsp->fRec37[0]) + 1e-20f);
			float fTemp12 = ((fTemp9 + dsp->fVec14[((dsp->IOTA - dsp->iConst38) & 8191)]) - (0.6f * dsp->fRec35[1]));
			dsp->fVec15[(dsp->IOTA & 2047)] = fTemp12;
			dsp->fRec35[0] = dsp->fVec15[((dsp->IOTA - dsp->iConst39) & 2047)];
			float fRec36 = (0.6f * fTemp12);
			dsp->fRec42[0] = ((fSlow25 * dsp->fRec42[1]) + (fSlow26 * (dsp->fRec3[1] + dsp->fRec3[2])));
			dsp->fRec41[0] = ((fSlow88 * dsp->fRec41[1]) + (fSlow89 * (dsp->fRec3[1] + (fSlow90 * dsp->fRec42[0]))));
			dsp->fVec16[(dsp->IOTA & 8191)] = ((0.353553f * dsp->fRec41[0]) + 1e-20f);
			float fTemp13 = ((dsp->fVec16[((dsp->IOTA - dsp->iConst43) & 8191)] + fTemp9) - (0.6f * dsp->fRec39[1]));
			dsp->fVec17[(dsp->IOTA & 1023)] = fTemp13;
			dsp->fRec39[0] = dsp->fVec17[((dsp->IOTA - dsp->iConst44) & 1023)];
			float fRec40 = (0.6f * fTemp13);
			float fTemp14 = (fRec40 + fRec36);
			float fTemp15 = (fRec28 + (fRec32 + fTemp14));
			dsp->fRec3[0] = (dsp->fRec11[1] + (dsp->fRec15[1] + (dsp->fRec19[1] + (dsp->fRec23[1] + (dsp->fRec27[1] + (dsp->fRec31[1] + (dsp->fRec35[1] + (dsp->fRec39[1] + (fRec12 + (fRec16 + (fRec20 + (fRec24 + fTemp15))))))))))));
			dsp->fRec4[0] = (0.f - ((dsp->fRec11[1] + (dsp->fRec15[1] + (dsp->fRec19[1] + (dsp->fRec23[1] + (fRec12 + (fRec16 + (fRec24 + fRec20))))))) - (dsp->fRec27[1] + (dsp->fRec31[1] + (dsp->fRec35[1] + (dsp->fRec39[1] + fTemp15))))));
			float fTemp16 = (fRec32 + fRec28);
			dsp->fRec5[0] = (0.f - ((dsp->fRec11[1] + (dsp->fRec15[1] + (dsp->fRec27[1] + (dsp->fRec31[1] + (fRec12 + (fRec16 + fTemp16)))))) - (dsp->fRec19[1] + (dsp->fRec23[1] + (dsp->fRec35[1] + (dsp->fRec39[1] + (fRec20 + (fRec24 + fTemp14))))))));
			dsp->fRec6[0] = (0.f - ((dsp->fRec19[1] + (dsp->fRec23[1] + (dsp->fRec27[1] + (dsp->fRec31[1] + (fRec20 + (fRec24 + fTemp16)))))) - (dsp->fRec11[1] + (dsp->fRec15[1] + (dsp->fRec35[1] + (dsp->fRec39[1] + (fRec12 + (fRec16 + fTemp14))))))));
			float fTemp17 = (fRec36 + fRec28);
			float fTemp18 = (fRec40 + fRec32);
			dsp->fRec7[0] = (0.f - ((dsp->fRec11[1] + (dsp->fRec19[1] + (dsp->fRec27[1] + (dsp->fRec35[1] + (fRec12 + (fRec20 + fTemp17)))))) - (dsp->fRec15[1] + (dsp->fRec23[1] + (dsp->fRec31[1] + (dsp->fRec39[1] + (fRec16 + (fRec24 + fTemp18))))))));
			dsp->fRec8[0] = (0.f - ((dsp->fRec15[1] + (dsp->fRec23[1] + (dsp->fRec27[1] + (dsp->fRec35[1] + (fRec16 + (fRec24 + fTemp17)))))) - (dsp->fRec11[1] + (dsp->fRec19[1] + (dsp->fRec31[1] + (dsp->fRec39[1] + (fRec12 + (fRec20 + fTemp18))))))));
			float fTemp19 = (fRec36 + fRec32);
			float fTemp20 = (fRec40 + fRec28);
			dsp->fRec9[0] = (0.f - ((dsp->fRec15[1] + (dsp->fRec19[1] + (dsp->fRec31[1] + (dsp->fRec35[1] + (fRec16 + (fRec20 + fTemp19)))))) - (dsp->fRec11[1] + (dsp->fRec23[1] + (dsp->fRec27[1] + (dsp->fRec39[1] + (fRec12 + (fRec24 + fTemp20))))))));
			dsp->fRec10[0] = (0.f - ((dsp->fRec11[1] + (dsp->fRec23[1] + (dsp->fRec31[1] + (dsp->fRec35[1] + (fRec12 + (fRec24 + fTemp19)))))) - (dsp->fRec15[1] + (dsp->fRec19[1] + (dsp->fRec27[1] + (dsp->fRec39[1] + (fRec16 + (fRec20 + fTemp20))))))));
			float fTemp21 = (0.37f * (dsp->fRec4[0] + dsp->fRec5[0]));
			dsp->fRec2[0] = (0.f - ((fTemp1 + (fSlow9 * dsp->fRec2[2])) - fTemp21));
			float fTemp22 = (fSlow9 * dsp->fRec2[0]);
			float fTemp23 = (0.5f * ((fTemp22 + (dsp->fRec2[2] + (fTemp21 + fTemp1))) + (fSlow7 * ((fTemp22 + (fTemp1 + dsp->fRec2[2])) - fTemp21))));
			dsp->fRec1[0] = (0.f - ((fTemp0 + (fSlow4 * dsp->fRec1[2])) - fTemp23));
			float fTemp24 = (fSlow4 * dsp->fRec1[0]);
			dsp->fRec43[0] = ((0.999f * dsp->fRec43[1]) + fSlow91);
			float fTemp25 = (1.f + dsp->fRec43[0]);
			float fTemp26 = (1.f - (0.5f * fTemp25));
			output0[i] = (FAUSTFLOAT)(dsp->fRec0[0] * ((0.25f * (((fTemp24 + (dsp->fRec1[2] + (fTemp23 + fTemp0))) + (fSlow2 * ((fTemp24 + (fTemp0 + dsp->fRec1[2])) - fTemp23))) * fTemp25)) + (fTemp26 * fTemp8)));
			float fTemp27 = (fSlow5 * dsp->fRec44[1]);
			float fTemp28 = (fSlow10 * dsp->fRec45[1]);
			float fTemp29 = (0.37f * (dsp->fRec4[0] - dsp->fRec5[0]));
			dsp->fRec45[0] = (0.f - ((fTemp28 + (fSlow9 * dsp->fRec45[2])) - fTemp29));
			float fTemp30 = (fSlow9 * dsp->fRec45[0]);
			float fTemp31 = (0.5f * ((fTemp30 + (dsp->fRec45[2] + (fTemp29 + fTemp28))) + (fSlow7 * ((fTemp30 + (fTemp28 + dsp->fRec45[2])) - fTemp29))));
			dsp->fRec44[0] = (0.f - ((fTemp27 + (fSlow4 * dsp->fRec44[2])) - fTemp31));
			float fTemp32 = (fSlow4 * dsp->fRec44[0]);
			output1[i] = (FAUSTFLOAT)(dsp->fRec0[0] * ((0.25f * (fTemp25 * ((fTemp32 + (dsp->fRec44[2] + (fTemp31 + fTemp27))) + (fSlow2 * ((fTemp32 + (fTemp27 + dsp->fRec44[2])) - fTemp31))))) + (fTemp26 * fTemp2)));
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fRec14[1] = dsp->fRec14[0];
			dsp->fRec13[1] = dsp->fRec13[0];
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec11[1] = dsp->fRec11[0];
			dsp->fRec18[1] = dsp->fRec18[0];
			dsp->fRec17[1] = dsp->fRec17[0];
			dsp->fRec15[1] = dsp->fRec15[0];
			dsp->fRec22[1] = dsp->fRec22[0];
			dsp->fRec21[1] = dsp->fRec21[0];
			dsp->fRec19[1] = dsp->fRec19[0];
			dsp->fRec26[1] = dsp->fRec26[0];
			dsp->fRec25[1] = dsp->fRec25[0];
			dsp->fRec23[1] = dsp->fRec23[0];
			dsp->fRec30[1] = dsp->fRec30[0];
			dsp->fRec29[1] = dsp->fRec29[0];
			dsp->fRec27[1] = dsp->fRec27[0];
			dsp->fRec34[1] = dsp->fRec34[0];
			dsp->fRec33[1] = dsp->fRec33[0];
			dsp->fRec31[1] = dsp->fRec31[0];
			dsp->fRec38[1] = dsp->fRec38[0];
			dsp->fRec37[1] = dsp->fRec37[0];
			dsp->fRec35[1] = dsp->fRec35[0];
			dsp->fRec42[1] = dsp->fRec42[0];
			dsp->fRec41[1] = dsp->fRec41[0];
			dsp->fRec39[1] = dsp->fRec39[0];
			dsp->fRec3[2] = dsp->fRec3[1];
			dsp->fRec3[1] = dsp->fRec3[0];
			dsp->fRec4[2] = dsp->fRec4[1];
			dsp->fRec4[1] = dsp->fRec4[0];
			dsp->fRec5[2] = dsp->fRec5[1];
			dsp->fRec5[1] = dsp->fRec5[0];
			dsp->fRec6[2] = dsp->fRec6[1];
			dsp->fRec6[1] = dsp->fRec6[0];
			dsp->fRec7[2] = dsp->fRec7[1];
			dsp->fRec7[1] = dsp->fRec7[0];
			dsp->fRec8[2] = dsp->fRec8[1];
			dsp->fRec8[1] = dsp->fRec8[0];
			dsp->fRec9[2] = dsp->fRec9[1];
			dsp->fRec9[1] = dsp->fRec9[0];
			dsp->fRec10[2] = dsp->fRec10[1];
			dsp->fRec10[1] = dsp->fRec10[0];
			dsp->fRec2[2] = dsp->fRec2[1];
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec1[2] = dsp->fRec1[1];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fRec43[1] = dsp->fRec43[0];
			dsp->fRec45[2] = dsp->fRec45[1];
			dsp->fRec45[1] = dsp->fRec45[0];
			dsp->fRec44[2] = dsp->fRec44[1];
			dsp->fRec44[1] = dsp->fRec44[0];

		}

	}

}

#ifdef __cplusplus
}
#endif

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_zitarev *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_zitarev_create(sp_zitarev **p)
{
    *p = malloc(sizeof(sp_zitarev));
    return SP_OK;
}

int sp_zitarev_destroy(sp_zitarev **p)
{
    sp_zitarev *pp = *p;
    zitarev *dsp = pp->ud;
    deletezitarev(dsp);
    free(*p);
    return SP_OK;
}

int sp_zitarev_init(sp_data *sp, sp_zitarev *p)
{
    zitarev *dsp = newzitarev();
    UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfacezitarev(dsp, &UI);
    initzitarev(dsp, sp->sr);

    p->in_delay=p->args[0];
    p->lf_x=p->args[1];
    p->rt60_low=p->args[2];
    p->rt60_mid=p->args[3];
    p->hf_damping=p->args[4];
    p->eq1_freq=p->args[5];
    p->eq1_level=p->args[6];
    p->eq2_freq=p->args[7];
    p->eq2_level=p->args[8];
    p->mix=p->args[9];
    p->level=p->args[10];

    p->ud = dsp;
    return SP_OK;
}

int sp_zitarev_compute(sp_data *sp, sp_zitarev *p, SPFLOAT *inL, SPFLOAT *inR, SPFLOAT *outL, SPFLOAT *outR)
{

    zitarev *dsp = p->ud;
    SPFLOAT out1 = 0, out2 = 0;
    SPFLOAT *faust_out[] = {&out1, &out2};
    SPFLOAT *faust_in[] = {inL, inR};
    computezitarev(dsp, 1, faust_in, faust_out);

    *outL = out1;
    *outR = out2;
    return SP_OK;
}

#endif
