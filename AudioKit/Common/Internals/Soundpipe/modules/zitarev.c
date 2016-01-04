/*
 * Zitarev
 *
 * This code has been generated FAUST.
 * It uses the zitarev module included in the FAUST 
 * standard library (FAUST port by Julius Smith).
 * It has been modified to work as a Soundpipe module.
 *
 * Original Author: Fons Adriaensen
 *
 */

#include <stdlib.h>
#include <math.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)

#ifndef FAUSTFLOAT
#define FAUSTFLOAT float
#endif  

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
	
	float fVec1[32768];
	float fVec4[32768];
	float fVec8[32768];
	float fVec6[16384];
	float fVec10[16384];
	float fVec12[16384];
	float fVec14[16384];
	float fVec16[16384];
	float fVec0[8192];
	float fVec2[8192];
	float fVec5[4096];
	float fVec7[4096];
	float fVec9[4096];
	float fVec13[4096];
	float fVec15[4096];
	float fVec3[2048];
	float fVec11[2048];
	float fVec17[2048];
	float fRec4[3];
	float fRec5[3];
	float fRec6[3];
	float fRec7[3];
	float fRec8[3];
	float fRec9[3];
	float fRec10[3];
	float fRec11[3];
	float fRec3[3];
	float fRec2[3];
	float fRec45[3];
	float fRec44[3];
	float fRec0[2];
	float fRec1[2];
	float fRec15[2];
	float fRec14[2];
	float fRec12[2];
	float fRec19[2];
	float fRec18[2];
	float fRec16[2];
	float fRec23[2];
	float fRec22[2];
	float fRec20[2];
	float fRec27[2];
	float fRec26[2];
	float fRec24[2];
	float fRec31[2];
	float fRec30[2];
	float fRec28[2];
	float fRec35[2];
	float fRec34[2];
	float fRec32[2];
	float fRec39[2];
	float fRec38[2];
	float fRec36[2];
	float fRec43[2];
	float fRec42[2];
	float fRec40[2];
	FAUSTFLOAT fHslider0;
	FAUSTFLOAT fHslider1;
	int IOTA;
	int fSamplingFreq;
	int iConst0;
	float fConst1;
	FAUSTFLOAT fHslider2;
	FAUSTFLOAT fHslider3;
	FAUSTFLOAT fHslider4;
	FAUSTFLOAT fHslider5;
	float fConst2;
	float fConst3;
	FAUSTFLOAT fHslider6;
	float fConst4;
	FAUSTFLOAT fHslider7;
	FAUSTFLOAT fHslider8;
	float fConst5;
	FAUSTFLOAT fHslider9;
	float fConst6;
	int iConst7;
	float fConst8;
	FAUSTFLOAT fHslider10;
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
	
} zitarev;

static zitarev* newzitarev() { 
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
	dsp->fHslider1 = (FAUSTFLOAT)1.;
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 2); i1 = (i1 + 1)) {
			dsp->fRec1[i1] = 0.f;
			
		}
		
	}
	dsp->IOTA = 0;
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 8192); i2 = (i2 + 1)) {
			dsp->fVec0[i2] = 0.f;
			
		}
		
	}
	dsp->iConst0 = min(192000, max(1, dsp->fSamplingFreq));
	dsp->fConst1 = (6.28319f / (float)dsp->iConst0);
	dsp->fHslider2 = (FAUSTFLOAT)1500.;
	dsp->fHslider3 = (FAUSTFLOAT)0.;
	dsp->fHslider4 = (FAUSTFLOAT)315.;
	dsp->fHslider5 = (FAUSTFLOAT)0.;
	dsp->fConst2 = floorf((0.5f + (0.219991f * (float)dsp->iConst0)));
	dsp->fConst3 = ((0.f - (6.90776f * dsp->fConst2)) / (float)dsp->iConst0);
	dsp->fHslider6 = (FAUSTFLOAT)2.;
	dsp->fConst4 = (6.28319f / (float)dsp->iConst0);
	dsp->fHslider7 = (FAUSTFLOAT)6000.;
	dsp->fHslider8 = (FAUSTFLOAT)3.;
	dsp->fConst5 = (3.14159f / (float)dsp->iConst0);
	dsp->fHslider9 = (FAUSTFLOAT)200.;
	/* C99 loop */
	{
		int i3;
		for (i3 = 0; (i3 < 2); i3 = (i3 + 1)) {
			dsp->fRec15[i3] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i4;
		for (i4 = 0; (i4 < 2); i4 = (i4 + 1)) {
			dsp->fRec14[i4] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i5;
		for (i5 = 0; (i5 < 32768); i5 = (i5 + 1)) {
			dsp->fVec1[i5] = 0.f;
			
		}
		
	}
	dsp->fConst6 = floorf((0.5f + (0.019123f * (float)dsp->iConst0)));
	dsp->iConst7 = (int)((int)(dsp->fConst2 - dsp->fConst6) & 32767);
	/* C99 loop */
	{
		int i6;
		for (i6 = 0; (i6 < 8192); i6 = (i6 + 1)) {
			dsp->fVec2[i6] = 0.f;
			
		}
		
	}
	dsp->fConst8 = (0.001f * (float)dsp->iConst0);
	dsp->fHslider10 = (FAUSTFLOAT)60.;
	/* C99 loop */
	{
		int i7;
		for (i7 = 0; (i7 < 2048); i7 = (i7 + 1)) {
			dsp->fVec3[i7] = 0.f;
			
		}
		
	}
	dsp->iConst9 = (int)((int)(dsp->fConst6 - 1.f) & 2047);
	/* C99 loop */
	{
		int i8;
		for (i8 = 0; (i8 < 2); i8 = (i8 + 1)) {
			dsp->fRec12[i8] = 0.f;
			
		}
		
	}
	dsp->fConst10 = floorf((0.5f + (0.256891f * (float)dsp->iConst0)));
	dsp->fConst11 = ((0.f - (6.90776f * dsp->fConst10)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i9;
		for (i9 = 0; (i9 < 2); i9 = (i9 + 1)) {
			dsp->fRec19[i9] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i10;
		for (i10 = 0; (i10 < 2); i10 = (i10 + 1)) {
			dsp->fRec18[i10] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i11;
		for (i11 = 0; (i11 < 32768); i11 = (i11 + 1)) {
			dsp->fVec4[i11] = 0.f;
			
		}
		
	}
	dsp->fConst12 = floorf((0.5f + (0.027333f * (float)dsp->iConst0)));
	dsp->iConst13 = (int)((int)(dsp->fConst10 - dsp->fConst12) & 32767);
	/* C99 loop */
	{
		int i12;
		for (i12 = 0; (i12 < 4096); i12 = (i12 + 1)) {
			dsp->fVec5[i12] = 0.f;
			
		}
		
	}
	dsp->iConst14 = (int)((int)(dsp->fConst12 - 1.f) & 4095);
	/* C99 loop */
	{
		int i13;
		for (i13 = 0; (i13 < 2); i13 = (i13 + 1)) {
			dsp->fRec16[i13] = 0.f;
			
		}
		
	}
	dsp->fConst15 = floorf((0.5f + (0.192303f * (float)dsp->iConst0)));
	dsp->fConst16 = ((0.f - (6.90776f * dsp->fConst15)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i14;
		for (i14 = 0; (i14 < 2); i14 = (i14 + 1)) {
			dsp->fRec23[i14] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i15;
		for (i15 = 0; (i15 < 2); i15 = (i15 + 1)) {
			dsp->fRec22[i15] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i16;
		for (i16 = 0; (i16 < 16384); i16 = (i16 + 1)) {
			dsp->fVec6[i16] = 0.f;
			
		}
		
	}
	dsp->fConst17 = floorf((0.5f + (0.029291f * (float)dsp->iConst0)));
	dsp->iConst18 = (int)((int)(dsp->fConst15 - dsp->fConst17) & 16383);
	/* C99 loop */
	{
		int i17;
		for (i17 = 0; (i17 < 4096); i17 = (i17 + 1)) {
			dsp->fVec7[i17] = 0.f;
			
		}
		
	}
	dsp->iConst19 = (int)((int)(dsp->fConst17 - 1.f) & 4095);
	/* C99 loop */
	{
		int i18;
		for (i18 = 0; (i18 < 2); i18 = (i18 + 1)) {
			dsp->fRec20[i18] = 0.f;
			
		}
		
	}
	dsp->fConst20 = floorf((0.5f + (0.210389f * (float)dsp->iConst0)));
	dsp->fConst21 = ((0.f - (6.90776f * dsp->fConst20)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i19;
		for (i19 = 0; (i19 < 2); i19 = (i19 + 1)) {
			dsp->fRec27[i19] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i20;
		for (i20 = 0; (i20 < 2); i20 = (i20 + 1)) {
			dsp->fRec26[i20] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i21;
		for (i21 = 0; (i21 < 32768); i21 = (i21 + 1)) {
			dsp->fVec8[i21] = 0.f;
			
		}
		
	}
	dsp->fConst22 = floorf((0.5f + (0.024421f * (float)dsp->iConst0)));
	dsp->iConst23 = (int)((int)(dsp->fConst20 - dsp->fConst22) & 32767);
	/* C99 loop */
	{
		int i22;
		for (i22 = 0; (i22 < 4096); i22 = (i22 + 1)) {
			dsp->fVec9[i22] = 0.f;
			
		}
		
	}
	dsp->iConst24 = (int)((int)(dsp->fConst22 - 1.f) & 4095);
	/* C99 loop */
	{
		int i23;
		for (i23 = 0; (i23 < 2); i23 = (i23 + 1)) {
			dsp->fRec24[i23] = 0.f;
			
		}
		
	}
	dsp->fConst25 = floorf((0.5f + (0.125f * (float)dsp->iConst0)));
	dsp->fConst26 = ((0.f - (6.90776f * dsp->fConst25)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i24;
		for (i24 = 0; (i24 < 2); i24 = (i24 + 1)) {
			dsp->fRec31[i24] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i25;
		for (i25 = 0; (i25 < 2); i25 = (i25 + 1)) {
			dsp->fRec30[i25] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i26;
		for (i26 = 0; (i26 < 16384); i26 = (i26 + 1)) {
			dsp->fVec10[i26] = 0.f;
			
		}
		
	}
	dsp->fConst27 = floorf((0.5f + (0.013458f * (float)dsp->iConst0)));
	dsp->iConst28 = (int)((int)(dsp->fConst25 - dsp->fConst27) & 16383);
	/* C99 loop */
	{
		int i27;
		for (i27 = 0; (i27 < 2048); i27 = (i27 + 1)) {
			dsp->fVec11[i27] = 0.f;
			
		}
		
	}
	dsp->iConst29 = (int)((int)(dsp->fConst27 - 1.f) & 2047);
	/* C99 loop */
	{
		int i28;
		for (i28 = 0; (i28 < 2); i28 = (i28 + 1)) {
			dsp->fRec28[i28] = 0.f;
			
		}
		
	}
	dsp->fConst30 = floorf((0.5f + (0.127837f * (float)dsp->iConst0)));
	dsp->fConst31 = ((0.f - (6.90776f * dsp->fConst30)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i29;
		for (i29 = 0; (i29 < 2); i29 = (i29 + 1)) {
			dsp->fRec35[i29] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i30;
		for (i30 = 0; (i30 < 2); i30 = (i30 + 1)) {
			dsp->fRec34[i30] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i31;
		for (i31 = 0; (i31 < 16384); i31 = (i31 + 1)) {
			dsp->fVec12[i31] = 0.f;
			
		}
		
	}
	dsp->fConst32 = floorf((0.5f + (0.031604f * (float)dsp->iConst0)));
	dsp->iConst33 = (int)((int)(dsp->fConst30 - dsp->fConst32) & 16383);
	/* C99 loop */
	{
		int i32;
		for (i32 = 0; (i32 < 4096); i32 = (i32 + 1)) {
			dsp->fVec13[i32] = 0.f;
			
		}
		
	}
	dsp->iConst34 = (int)((int)(dsp->fConst32 - 1.f) & 4095);
	/* C99 loop */
	{
		int i33;
		for (i33 = 0; (i33 < 2); i33 = (i33 + 1)) {
			dsp->fRec32[i33] = 0.f;
			
		}
		
	}
	dsp->fConst35 = floorf((0.5f + (0.174713f * (float)dsp->iConst0)));
	dsp->fConst36 = ((0.f - (6.90776f * dsp->fConst35)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i34;
		for (i34 = 0; (i34 < 2); i34 = (i34 + 1)) {
			dsp->fRec39[i34] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i35;
		for (i35 = 0; (i35 < 2); i35 = (i35 + 1)) {
			dsp->fRec38[i35] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i36;
		for (i36 = 0; (i36 < 16384); i36 = (i36 + 1)) {
			dsp->fVec14[i36] = 0.f;
			
		}
		
	}
	dsp->fConst37 = floorf((0.5f + (0.022904f * (float)dsp->iConst0)));
	dsp->iConst38 = (int)((int)(dsp->fConst35 - dsp->fConst37) & 16383);
	/* C99 loop */
	{
		int i37;
		for (i37 = 0; (i37 < 4096); i37 = (i37 + 1)) {
			dsp->fVec15[i37] = 0.f;
			
		}
		
	}
	dsp->iConst39 = (int)((int)(dsp->fConst37 - 1.f) & 4095);
	/* C99 loop */
	{
		int i38;
		for (i38 = 0; (i38 < 2); i38 = (i38 + 1)) {
			dsp->fRec36[i38] = 0.f;
			
		}
		
	}
	dsp->fConst40 = floorf((0.5f + (0.153129f * (float)dsp->iConst0)));
	dsp->fConst41 = ((0.f - (6.90776f * dsp->fConst40)) / (float)dsp->iConst0);
	/* C99 loop */
	{
		int i39;
		for (i39 = 0; (i39 < 2); i39 = (i39 + 1)) {
			dsp->fRec43[i39] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i40;
		for (i40 = 0; (i40 < 2); i40 = (i40 + 1)) {
			dsp->fRec42[i40] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i41;
		for (i41 = 0; (i41 < 16384); i41 = (i41 + 1)) {
			dsp->fVec16[i41] = 0.f;
			
		}
		
	}
	dsp->fConst42 = floorf((0.5f + (0.020346f * (float)dsp->iConst0)));
	dsp->iConst43 = (int)((int)(dsp->fConst40 - dsp->fConst42) & 16383);
	/* C99 loop */
	{
		int i42;
		for (i42 = 0; (i42 < 2048); i42 = (i42 + 1)) {
			dsp->fVec17[i42] = 0.f;
			
		}
		
	}
	dsp->iConst44 = (int)((int)(dsp->fConst42 - 1.f) & 2047);
	/* C99 loop */
	{
		int i43;
		for (i43 = 0; (i43 < 2); i43 = (i43 + 1)) {
			dsp->fRec40[i43] = 0.f;
			
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
			dsp->fRec11[i51] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i52;
		for (i52 = 0; (i52 < 3); i52 = (i52 + 1)) {
			dsp->fRec3[i52] = 0.f;
			
		}
		
	}
	/* C99 loop */
	{
		int i53;
		for (i53 = 0; (i53 < 3); i53 = (i53 + 1)) {
			dsp->fRec2[i53] = 0.f;
			
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
	interface->addHorizontalSlider(interface->uiInterface, "in_delay", &dsp->fHslider10, 60.f, 10.f, 100.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "lf_x", &dsp->fHslider9, 200.f, 50.f, 1000.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "rt60_low", &dsp->fHslider8, 3.f, 1.f, 8.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "rt60_mid", &dsp->fHslider6, 2.f, 1.f, 8.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "hf_damping", &dsp->fHslider7, 6000.f, 1500.f, 47040.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "eq1_freq", &dsp->fHslider4, 315.f, 40.f, 2500.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "eq1_level", &dsp->fHslider5, 0.f, -15.f, 15.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "eq2_freq", &dsp->fHslider2, 1500.f, 160.f, 10000.f, 1.f);
	interface->addHorizontalSlider(interface->uiInterface, "eq2_level", &dsp->fHslider3, 0.f, -15.f, 15.f, 0.1f);
	interface->addHorizontalSlider(interface->uiInterface, "mix", &dsp->fHslider1, 1.f, 0.f, 1.f, 0.001f);
	interface->addHorizontalSlider(interface->uiInterface, "level", &dsp->fHslider0, -20.f, -70.f, 40.f, 0.1f);
}

static void computezitarev(zitarev* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* input1 = inputs[1];
	FAUSTFLOAT* output0 = outputs[0];
	FAUSTFLOAT* output1 = outputs[1];
	float fSlow0 = (0.001f * powf(10.f, (0.05f * (float)dsp->fHslider0)));
	float fSlow1 = (0.001f * (float)dsp->fHslider1);
	float fSlow2 = (float)dsp->fHslider2;
	float fSlow3 = powf(10.f, (0.05f * (float)dsp->fHslider3));
	float fSlow4 = (dsp->fConst1 * (fSlow2 / sqrtf(max(0.f, fSlow3))));
	float fSlow5 = ((1.f - fSlow4) / (1.f + fSlow4));
	float fSlow6 = ((0.f - cosf((dsp->fConst1 * fSlow2))) * (1.f + fSlow5));
	float fSlow7 = (float)dsp->fHslider4;
	float fSlow8 = powf(10.f, (0.05f * (float)dsp->fHslider5));
	float fSlow9 = (dsp->fConst1 * (fSlow7 / sqrtf(max(0.f, fSlow8))));
	float fSlow10 = ((1.f - fSlow9) / (1.f + fSlow9));
	float fSlow11 = ((0.f - cosf((dsp->fConst1 * fSlow7))) * (1.f + fSlow10));
	float fSlow12 = (float)dsp->fHslider6;
	float fSlow13 = expf((dsp->fConst3 / fSlow12));
	float fSlow14 = faustpower2_f(fSlow13);
	float fSlow15 = cosf((dsp->fConst4 * (float)dsp->fHslider7));
	float fSlow16 = (1.f - (fSlow14 * fSlow15));
	float fSlow17 = (1.f - fSlow14);
	float fSlow18 = (fSlow16 / fSlow17);
	float fSlow19 = sqrtf(max(0.f, ((faustpower2_f(fSlow16) / faustpower2_f(fSlow17)) - 1.f)));
	float fSlow20 = (fSlow18 - fSlow19);
	float fSlow21 = (((1.f + fSlow19) - fSlow18) * fSlow13);
	float fSlow22 = (float)dsp->fHslider8;
	float fSlow23 = ((expf((dsp->fConst3 / fSlow22)) / fSlow13) - 1.f);
	float fSlow24 = (1.f / tanf((dsp->fConst5 * (float)dsp->fHslider9)));
	float fSlow25 = (1.f + fSlow24);
	float fSlow26 = (0.f - ((1.f - fSlow24) / fSlow25));
	float fSlow27 = (1.f / fSlow25);
	int iSlow28 = (int)((int)(dsp->fConst8 * (float)dsp->fHslider10) & 8191);
	float fSlow29 = expf((dsp->fConst11 / fSlow12));
	float fSlow30 = faustpower2_f(fSlow29);
	float fSlow31 = (1.f - (fSlow15 * fSlow30));
	float fSlow32 = (1.f - fSlow30);
	float fSlow33 = (fSlow31 / fSlow32);
	float fSlow34 = sqrtf(max(0.f, ((faustpower2_f(fSlow31) / faustpower2_f(fSlow32)) - 1.f)));
	float fSlow35 = (fSlow33 - fSlow34);
	float fSlow36 = (((1.f + fSlow34) - fSlow33) * fSlow29);
	float fSlow37 = ((expf((dsp->fConst11 / fSlow22)) / fSlow29) - 1.f);
	float fSlow38 = expf((dsp->fConst16 / fSlow12));
	float fSlow39 = faustpower2_f(fSlow38);
	float fSlow40 = (1.f - (fSlow15 * fSlow39));
	float fSlow41 = (1.f - fSlow39);
	float fSlow42 = (fSlow40 / fSlow41);
	float fSlow43 = sqrtf(max(0.f, ((faustpower2_f(fSlow40) / faustpower2_f(fSlow41)) - 1.f)));
	float fSlow44 = (fSlow42 - fSlow43);
	float fSlow45 = (((1.f + fSlow43) - fSlow42) * fSlow38);
	float fSlow46 = ((expf((dsp->fConst16 / fSlow22)) / fSlow38) - 1.f);
	float fSlow47 = expf((dsp->fConst21 / fSlow12));
	float fSlow48 = faustpower2_f(fSlow47);
	float fSlow49 = (1.f - (fSlow15 * fSlow48));
	float fSlow50 = (1.f - fSlow48);
	float fSlow51 = (fSlow49 / fSlow50);
	float fSlow52 = sqrtf(max(0.f, ((faustpower2_f(fSlow49) / faustpower2_f(fSlow50)) - 1.f)));
	float fSlow53 = (fSlow51 - fSlow52);
	float fSlow54 = (((1.f + fSlow52) - fSlow51) * fSlow47);
	float fSlow55 = ((expf((dsp->fConst21 / fSlow22)) / fSlow47) - 1.f);
	float fSlow56 = expf((dsp->fConst26 / fSlow12));
	float fSlow57 = faustpower2_f(fSlow56);
	float fSlow58 = (1.f - (fSlow15 * fSlow57));
	float fSlow59 = (1.f - fSlow57);
	float fSlow60 = (fSlow58 / fSlow59);
	float fSlow61 = sqrtf(max(0.f, ((faustpower2_f(fSlow58) / faustpower2_f(fSlow59)) - 1.f)));
	float fSlow62 = (fSlow60 - fSlow61);
	float fSlow63 = (((1.f + fSlow61) - fSlow60) * fSlow56);
	float fSlow64 = ((expf((dsp->fConst26 / fSlow22)) / fSlow56) - 1.f);
	float fSlow65 = expf((dsp->fConst31 / fSlow12));
	float fSlow66 = faustpower2_f(fSlow65);
	float fSlow67 = (1.f - (fSlow15 * fSlow66));
	float fSlow68 = (1.f - fSlow66);
	float fSlow69 = (fSlow67 / fSlow68);
	float fSlow70 = sqrtf(max(0.f, ((faustpower2_f(fSlow67) / faustpower2_f(fSlow68)) - 1.f)));
	float fSlow71 = (fSlow69 - fSlow70);
	float fSlow72 = (((1.f + fSlow70) - fSlow69) * fSlow65);
	float fSlow73 = ((expf((dsp->fConst31 / fSlow22)) / fSlow65) - 1.f);
	float fSlow74 = expf((dsp->fConst36 / fSlow12));
	float fSlow75 = faustpower2_f(fSlow74);
	float fSlow76 = (1.f - (fSlow15 * fSlow75));
	float fSlow77 = (1.f - fSlow75);
	float fSlow78 = (fSlow76 / fSlow77);
	float fSlow79 = sqrtf(max(0.f, ((faustpower2_f(fSlow76) / faustpower2_f(fSlow77)) - 1.f)));
	float fSlow80 = (fSlow78 - fSlow79);
	float fSlow81 = (((1.f + fSlow79) - fSlow78) * fSlow74);
	float fSlow82 = ((expf((dsp->fConst36 / fSlow22)) / fSlow74) - 1.f);
	float fSlow83 = expf((dsp->fConst41 / fSlow12));
	float fSlow84 = faustpower2_f(fSlow83);
	float fSlow85 = (1.f - (fSlow15 * fSlow84));
	float fSlow86 = (1.f - fSlow84);
	float fSlow87 = (fSlow85 / fSlow86);
	float fSlow88 = sqrtf(max(0.f, ((faustpower2_f(fSlow85) / faustpower2_f(fSlow86)) - 1.f)));
	float fSlow89 = (fSlow87 - fSlow88);
	float fSlow90 = (((1.f + fSlow88) - fSlow87) * fSlow83);
	float fSlow91 = ((expf((dsp->fConst41 / fSlow22)) / fSlow83) - 1.f);
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			dsp->fRec0[0] = ((0.999f * dsp->fRec0[1]) + fSlow0);
			dsp->fRec1[0] = ((0.999f * dsp->fRec1[1]) + fSlow1);
			float fTemp0 = (1.f - dsp->fRec1[0]);
			float fTemp1 = (float)input0[i];
			dsp->fVec0[(dsp->IOTA & 8191)] = fTemp1;
			float fTemp2 = (fSlow6 * dsp->fRec2[1]);
			float fTemp3 = (fSlow11 * dsp->fRec3[1]);
			dsp->fRec15[0] = ((fSlow26 * dsp->fRec15[1]) + (fSlow27 * (dsp->fRec11[1] + dsp->fRec11[2])));
			dsp->fRec14[0] = ((fSlow20 * dsp->fRec14[1]) + (fSlow21 * (dsp->fRec11[1] + (fSlow23 * dsp->fRec15[0]))));
			dsp->fVec1[(dsp->IOTA & 32767)] = ((0.353553f * dsp->fRec14[0]) + 1e-20f);
			float fTemp4 = (float)input1[i];
			dsp->fVec2[(dsp->IOTA & 8191)] = fTemp4;
			float fTemp5 = (0.3f * dsp->fVec2[((dsp->IOTA - iSlow28) & 8191)]);
			float fTemp6 = (((0.6f * dsp->fRec12[1]) + dsp->fVec1[((dsp->IOTA - dsp->iConst7) & 32767)]) - fTemp5);
			dsp->fVec3[(dsp->IOTA & 2047)] = fTemp6;
			dsp->fRec12[0] = dsp->fVec3[((dsp->IOTA - dsp->iConst9) & 2047)];
			float fRec13 = (0.f - (0.6f * fTemp6));
			dsp->fRec19[0] = ((fSlow26 * dsp->fRec19[1]) + (fSlow27 * (dsp->fRec7[1] + dsp->fRec7[2])));
			dsp->fRec18[0] = ((fSlow35 * dsp->fRec18[1]) + (fSlow36 * (dsp->fRec7[1] + (fSlow37 * dsp->fRec19[0]))));
			dsp->fVec4[(dsp->IOTA & 32767)] = ((0.353553f * dsp->fRec18[0]) + 1e-20f);
			float fTemp7 = (((0.6f * dsp->fRec16[1]) + dsp->fVec4[((dsp->IOTA - dsp->iConst13) & 32767)]) - fTemp5);
			dsp->fVec5[(dsp->IOTA & 4095)] = fTemp7;
			dsp->fRec16[0] = dsp->fVec5[((dsp->IOTA - dsp->iConst14) & 4095)];
			float fRec17 = (0.f - (0.6f * fTemp7));
			dsp->fRec23[0] = ((fSlow26 * dsp->fRec23[1]) + (fSlow27 * (dsp->fRec9[1] + dsp->fRec9[2])));
			dsp->fRec22[0] = ((fSlow44 * dsp->fRec22[1]) + (fSlow45 * (dsp->fRec9[1] + (fSlow46 * dsp->fRec23[0]))));
			dsp->fVec6[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec22[0]) + 1e-20f);
			float fTemp8 = (dsp->fVec6[((dsp->IOTA - dsp->iConst18) & 16383)] + (fTemp5 + (0.6f * dsp->fRec20[1])));
			dsp->fVec7[(dsp->IOTA & 4095)] = fTemp8;
			dsp->fRec20[0] = dsp->fVec7[((dsp->IOTA - dsp->iConst19) & 4095)];
			float fRec21 = (0.f - (0.6f * fTemp8));
			dsp->fRec27[0] = ((fSlow26 * dsp->fRec27[1]) + (fSlow27 * (dsp->fRec5[1] + dsp->fRec5[2])));
			dsp->fRec26[0] = ((fSlow53 * dsp->fRec26[1]) + (fSlow54 * (dsp->fRec5[1] + (fSlow55 * dsp->fRec27[0]))));
			dsp->fVec8[(dsp->IOTA & 32767)] = ((0.353553f * dsp->fRec26[0]) + 1e-20f);
			float fTemp9 = (fTemp5 + ((0.6f * dsp->fRec24[1]) + dsp->fVec8[((dsp->IOTA - dsp->iConst23) & 32767)]));
			dsp->fVec9[(dsp->IOTA & 4095)] = fTemp9;
			dsp->fRec24[0] = dsp->fVec9[((dsp->IOTA - dsp->iConst24) & 4095)];
			float fRec25 = (0.f - (0.6f * fTemp9));
			dsp->fRec31[0] = ((fSlow26 * dsp->fRec31[1]) + (fSlow27 * (dsp->fRec10[1] + dsp->fRec10[2])));
			dsp->fRec30[0] = ((fSlow62 * dsp->fRec30[1]) + (fSlow63 * (dsp->fRec10[1] + (fSlow64 * dsp->fRec31[0]))));
			dsp->fVec10[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec30[0]) + 1e-20f);
			float fTemp10 = (0.3f * dsp->fVec0[((dsp->IOTA - iSlow28) & 8191)]);
			float fTemp11 = (dsp->fVec10[((dsp->IOTA - dsp->iConst28) & 16383)] - (fTemp10 + (0.6f * dsp->fRec28[1])));
			dsp->fVec11[(dsp->IOTA & 2047)] = fTemp11;
			dsp->fRec28[0] = dsp->fVec11[((dsp->IOTA - dsp->iConst29) & 2047)];
			float fRec29 = (0.6f * fTemp11);
			dsp->fRec35[0] = ((fSlow26 * dsp->fRec35[1]) + (fSlow27 * (dsp->fRec6[1] + dsp->fRec6[2])));
			dsp->fRec34[0] = ((fSlow71 * dsp->fRec34[1]) + (fSlow72 * (dsp->fRec6[1] + (fSlow73 * dsp->fRec35[0]))));
			dsp->fVec12[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec34[0]) + 1e-20f);
			float fTemp12 = (dsp->fVec12[((dsp->IOTA - dsp->iConst33) & 16383)] - (fTemp10 + (0.6f * dsp->fRec32[1])));
			dsp->fVec13[(dsp->IOTA & 4095)] = fTemp12;
			dsp->fRec32[0] = dsp->fVec13[((dsp->IOTA - dsp->iConst34) & 4095)];
			float fRec33 = (0.6f * fTemp12);
			dsp->fRec39[0] = ((fSlow26 * dsp->fRec39[1]) + (fSlow27 * (dsp->fRec8[1] + dsp->fRec8[2])));
			dsp->fRec38[0] = ((fSlow80 * dsp->fRec38[1]) + (fSlow81 * (dsp->fRec8[1] + (fSlow82 * dsp->fRec39[0]))));
			dsp->fVec14[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec38[0]) + 1e-20f);
			float fTemp13 = ((fTemp10 + dsp->fVec14[((dsp->IOTA - dsp->iConst38) & 16383)]) - (0.6f * dsp->fRec36[1]));
			dsp->fVec15[(dsp->IOTA & 4095)] = fTemp13;
			dsp->fRec36[0] = dsp->fVec15[((dsp->IOTA - dsp->iConst39) & 4095)];
			float fRec37 = (0.6f * fTemp13);
			dsp->fRec43[0] = ((fSlow26 * dsp->fRec43[1]) + (fSlow27 * (dsp->fRec4[1] + dsp->fRec4[2])));
			dsp->fRec42[0] = ((fSlow89 * dsp->fRec42[1]) + (fSlow90 * (dsp->fRec4[1] + (fSlow91 * dsp->fRec43[0]))));
			dsp->fVec16[(dsp->IOTA & 16383)] = ((0.353553f * dsp->fRec42[0]) + 1e-20f);
			float fTemp14 = ((dsp->fVec16[((dsp->IOTA - dsp->iConst43) & 16383)] + fTemp10) - (0.6f * dsp->fRec40[1]));
			dsp->fVec17[(dsp->IOTA & 2047)] = fTemp14;
			dsp->fRec40[0] = dsp->fVec17[((dsp->IOTA - dsp->iConst44) & 2047)];
			float fRec41 = (0.6f * fTemp14);
			float fTemp15 = (fRec41 + fRec37);
			float fTemp16 = (fRec29 + (fRec33 + fTemp15));
			dsp->fRec4[0] = (dsp->fRec12[1] + (dsp->fRec16[1] + (dsp->fRec20[1] + (dsp->fRec24[1] + (dsp->fRec28[1] + (dsp->fRec32[1] + (dsp->fRec36[1] + (dsp->fRec40[1] + (fRec13 + (fRec17 + (fRec21 + (fRec25 + fTemp16))))))))))));
			dsp->fRec5[0] = (0.f - ((dsp->fRec12[1] + (dsp->fRec16[1] + (dsp->fRec20[1] + (dsp->fRec24[1] + (fRec13 + (fRec17 + (fRec25 + fRec21))))))) - (dsp->fRec28[1] + (dsp->fRec32[1] + (dsp->fRec36[1] + (dsp->fRec40[1] + fTemp16))))));
			float fTemp17 = (fRec33 + fRec29);
			dsp->fRec6[0] = (0.f - ((dsp->fRec12[1] + (dsp->fRec16[1] + (dsp->fRec28[1] + (dsp->fRec32[1] + (fRec13 + (fRec17 + fTemp17)))))) - (dsp->fRec20[1] + (dsp->fRec24[1] + (dsp->fRec36[1] + (dsp->fRec40[1] + (fRec21 + (fRec25 + fTemp15))))))));
			dsp->fRec7[0] = (0.f - ((dsp->fRec20[1] + (dsp->fRec24[1] + (dsp->fRec28[1] + (dsp->fRec32[1] + (fRec21 + (fRec25 + fTemp17)))))) - (dsp->fRec12[1] + (dsp->fRec16[1] + (dsp->fRec36[1] + (dsp->fRec40[1] + (fRec13 + (fRec17 + fTemp15))))))));
			float fTemp18 = (fRec37 + fRec29);
			float fTemp19 = (fRec41 + fRec33);
			dsp->fRec8[0] = (0.f - ((dsp->fRec12[1] + (dsp->fRec20[1] + (dsp->fRec28[1] + (dsp->fRec36[1] + (fRec13 + (fRec21 + fTemp18)))))) - (dsp->fRec16[1] + (dsp->fRec24[1] + (dsp->fRec32[1] + (dsp->fRec40[1] + (fRec17 + (fRec25 + fTemp19))))))));
			dsp->fRec9[0] = (0.f - ((dsp->fRec16[1] + (dsp->fRec24[1] + (dsp->fRec28[1] + (dsp->fRec36[1] + (fRec17 + (fRec25 + fTemp18)))))) - (dsp->fRec12[1] + (dsp->fRec20[1] + (dsp->fRec32[1] + (dsp->fRec40[1] + (fRec13 + (fRec21 + fTemp19))))))));
			float fTemp20 = (fRec37 + fRec33);
			float fTemp21 = (fRec41 + fRec29);
			dsp->fRec10[0] = (0.f - ((dsp->fRec16[1] + (dsp->fRec20[1] + (dsp->fRec32[1] + (dsp->fRec36[1] + (fRec17 + (fRec21 + fTemp20)))))) - (dsp->fRec12[1] + (dsp->fRec24[1] + (dsp->fRec28[1] + (dsp->fRec40[1] + (fRec13 + (fRec25 + fTemp21))))))));
			dsp->fRec11[0] = (0.f - ((dsp->fRec12[1] + (dsp->fRec24[1] + (dsp->fRec32[1] + (dsp->fRec36[1] + (fRec13 + (fRec25 + fTemp20)))))) - (dsp->fRec16[1] + (dsp->fRec20[1] + (dsp->fRec28[1] + (dsp->fRec40[1] + (fRec17 + (fRec21 + fTemp21))))))));
			float fTemp22 = (0.37f * (dsp->fRec5[0] + dsp->fRec6[0]));
			dsp->fRec3[0] = (0.f - ((fTemp3 + (fSlow10 * dsp->fRec3[2])) - fTemp22));
			float fTemp23 = (fSlow10 * dsp->fRec3[0]);
			float fTemp24 = (0.5f * ((fTemp23 + (dsp->fRec3[2] + (fTemp22 + fTemp3))) + (fSlow8 * ((fTemp23 + (fTemp3 + dsp->fRec3[2])) - fTemp22))));
			dsp->fRec2[0] = (0.f - ((fTemp2 + (fSlow5 * dsp->fRec2[2])) - fTemp24));
			float fTemp25 = (fSlow5 * dsp->fRec2[0]);
			output0[i] = (FAUSTFLOAT)(dsp->fRec0[0] * ((fTemp0 * fTemp1) + (0.5f * (dsp->fRec1[0] * ((fTemp25 + (dsp->fRec2[2] + (fTemp24 + fTemp2))) + (fSlow3 * ((fTemp25 + (fTemp2 + dsp->fRec2[2])) - fTemp24)))))));
			float fTemp26 = (fSlow6 * dsp->fRec44[1]);
			float fTemp27 = (fSlow11 * dsp->fRec45[1]);
			float fTemp28 = (0.37f * (dsp->fRec5[0] - dsp->fRec6[0]));
			dsp->fRec45[0] = (0.f - ((fTemp27 + (fSlow10 * dsp->fRec45[2])) - fTemp28));
			float fTemp29 = (fSlow10 * dsp->fRec45[0]);
			float fTemp30 = (0.5f * ((fTemp29 + (dsp->fRec45[2] + (fTemp28 + fTemp27))) + (fSlow8 * ((fTemp29 + (fTemp27 + dsp->fRec45[2])) - fTemp28))));
			dsp->fRec44[0] = (0.f - ((fTemp26 + (fSlow5 * dsp->fRec44[2])) - fTemp30));
			float fTemp31 = (fSlow5 * dsp->fRec44[0]);
			output1[i] = (FAUSTFLOAT)(dsp->fRec0[0] * ((fTemp0 * fTemp4) + (0.5f * (dsp->fRec1[0] * ((fTemp31 + (dsp->fRec44[2] + (fTemp30 + fTemp26))) + (fSlow3 * ((fTemp31 + (fTemp26 + dsp->fRec44[2])) - fTemp30)))))));
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->IOTA = (dsp->IOTA + 1);
			dsp->fRec15[1] = dsp->fRec15[0];
			dsp->fRec14[1] = dsp->fRec14[0];
			dsp->fRec12[1] = dsp->fRec12[0];
			dsp->fRec19[1] = dsp->fRec19[0];
			dsp->fRec18[1] = dsp->fRec18[0];
			dsp->fRec16[1] = dsp->fRec16[0];
			dsp->fRec23[1] = dsp->fRec23[0];
			dsp->fRec22[1] = dsp->fRec22[0];
			dsp->fRec20[1] = dsp->fRec20[0];
			dsp->fRec27[1] = dsp->fRec27[0];
			dsp->fRec26[1] = dsp->fRec26[0];
			dsp->fRec24[1] = dsp->fRec24[0];
			dsp->fRec31[1] = dsp->fRec31[0];
			dsp->fRec30[1] = dsp->fRec30[0];
			dsp->fRec28[1] = dsp->fRec28[0];
			dsp->fRec35[1] = dsp->fRec35[0];
			dsp->fRec34[1] = dsp->fRec34[0];
			dsp->fRec32[1] = dsp->fRec32[0];
			dsp->fRec39[1] = dsp->fRec39[0];
			dsp->fRec38[1] = dsp->fRec38[0];
			dsp->fRec36[1] = dsp->fRec36[0];
			dsp->fRec43[1] = dsp->fRec43[0];
			dsp->fRec42[1] = dsp->fRec42[0];
			dsp->fRec40[1] = dsp->fRec40[0];
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
			dsp->fRec11[2] = dsp->fRec11[1];
			dsp->fRec11[1] = dsp->fRec11[0];
			dsp->fRec3[2] = dsp->fRec3[1];
			dsp->fRec3[1] = dsp->fRec3[0];
			dsp->fRec2[2] = dsp->fRec2[1];
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec45[2] = dsp->fRec45[1];
			dsp->fRec45[1] = dsp->fRec45[0];
			dsp->fRec44[2] = dsp->fRec44[1];
			dsp->fRec44[1] = dsp->fRec44[0];
			
		}
		
	}
	
}

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
    zitarev *dsp = pp->faust;
    deletezitarev (dsp);
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

    p->in_delay = p->args[0]; 
    p->lf_x = p->args[1]; 
    p->rt60_low = p->args[2]; 
    p->rt60_mid = p->args[3]; 
    p->hf_damping = p->args[4]; 
    p->eq1_freq = p->args[5]; 
    p->eq1_level = p->args[6]; 
    p->eq2_freq = p->args[7]; 
    p->eq2_level = p->args[8]; 
    p->mix = p->args[9]; 
    p->level = p->args[10];

    p->faust = dsp;
    return SP_OK;
}

int sp_zitarev_compute(sp_data *sp, sp_zitarev *p, SPFLOAT *in1, SPFLOAT *in2, SPFLOAT *out1, SPFLOAT *out2) 
{

    zitarev *dsp = p->faust;
    SPFLOAT *faust_out[] = {out1, out2};
    SPFLOAT *faust_in[] = {in1, in2};
    computezitarev(dsp, 1, faust_in, faust_out);
    return SP_OK;
}
