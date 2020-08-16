#include <math.h>
#include <stdlib.h>
#include "soundpipe.h"
#include "CUI.h"

#define max(a,b) ((a < b) ? b : a)
#define min(a,b) ((a < b) ? a : b)


#ifndef FAUSTFLOAT
#define FAUSTFLOAT SPFLOAT
#endif

static float faustpower2_f(float value) {
	return (value * value);

}

typedef struct {

	float fRec0[3];
	float fRec3[3];
	float fRec4[3];
	float fRec7[3];
	float fRec8[3];
	float fRec11[3];
	float fRec12[3];
	float fRec15[3];
	float fRec16[3];
	float fRec19[3];
	float fRec20[3];
	float fRec23[3];
	float fRec24[3];
	float fRec27[3];
	float fRec28[3];
	float fRec31[3];
	float fRec32[3];
	float fRec35[3];
	float fRec36[3];
	float fRec39[3];
	float fRec40[3];
	float fRec43[3];
	float fRec44[3];
	float fRec47[3];
	float fRec48[3];
	float fRec51[3];
	float fRec52[3];
	float fRec55[3];
	float fRec56[3];
	float fRec59[3];
	float fRec60[3];
	float fRec63[3];
	float fRec2[2];
	float fRec1[2];
	float fRec6[2];
	float fRec5[2];
	float fRec10[2];
	float fRec9[2];
	float fRec14[2];
	float fRec13[2];
	float fRec18[2];
	float fRec17[2];
	float fRec22[2];
	float fRec21[2];
	float fRec26[2];
	float fRec25[2];
	float fRec30[2];
	float fRec29[2];
	float fRec34[2];
	float fRec33[2];
	float fRec38[2];
	float fRec37[2];
	float fRec42[2];
	float fRec41[2];
	float fRec46[2];
	float fRec45[2];
	float fRec50[2];
	float fRec49[2];
	float fRec54[2];
	float fRec53[2];
	float fRec58[2];
	float fRec57[2];
	float fRec62[2];
	float fRec61[2];
	int fSamplingFreq;
	int iConst0;
	float fConst1;
	float fConst2;
	FAUSTFLOAT fHslider0;
	float fConst3;
	float fConst4;
	float fConst5;
	FAUSTFLOAT fHslider1;
	FAUSTFLOAT fHslider2;
	float fConst6;
	float fConst7;
	float fConst8;
	float fConst9;
	float fConst10;
	float fConst11;
	float fConst12;
	float fConst13;
	float fConst14;
	float fConst15;
	float fConst16;
	float fConst17;
	float fConst18;
	float fConst19;
	float fConst20;
	float fConst21;
	float fConst22;
	float fConst23;
	float fConst24;
	float fConst25;
	float fConst26;
	float fConst27;
	float fConst28;
	float fConst29;
	float fConst30;
	float fConst31;
	float fConst32;
	float fConst33;
	float fConst34;
	float fConst35;
	float fConst36;
	float fConst37;
	float fConst38;
	float fConst39;
	float fConst40;
	float fConst41;
	float fConst42;
	float fConst43;
	float fConst44;
	float fConst45;
	float fConst46;
	float fConst47;
	float fConst48;
	float fConst49;
	float fConst50;
	float fConst51;
	float fConst52;
	float fConst53;
	float fConst54;
	float fConst55;
	float fConst56;
	float fConst57;
	float fConst58;
	float fConst59;
	float fConst60;
	float fConst61;
	float fConst62;
	float fConst63;
	float fConst64;
	float fConst65;

} vocoder;

static vocoder* newvocoder() {
	vocoder* dsp = (vocoder*)malloc(sizeof(vocoder));
	return dsp;
}

static void deletevocoder(vocoder* dsp) {
	free(dsp);
}


static void instanceInitvocoder(vocoder* dsp, int samplingFreq) {
	dsp->fSamplingFreq = samplingFreq;
	dsp->iConst0 = min(192000, max(1, dsp->fSamplingFreq));
	dsp->fConst1 = tan((115.99f / (float)dsp->iConst0));
	dsp->fConst2 = (1.f / dsp->fConst1);
	dsp->fHslider0 = (FAUSTFLOAT)0.5;
	dsp->fConst3 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst1))));
	/* C99 loop */
	{
		int i0;
		for (i0 = 0; (i0 < 3); i0 = (i0 + 1)) {
			dsp->fRec0[i0] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i1;
		for (i1 = 0; (i1 < 3); i1 = (i1 + 1)) {
			dsp->fRec3[i1] = 0.f;

		}

	}
	dsp->fConst4 = (0.f - dsp->fConst2);
	dsp->fConst5 = (1.f / (float)dsp->iConst0);
	dsp->fHslider1 = (FAUSTFLOAT)0.01;
	dsp->fHslider2 = (FAUSTFLOAT)0.01;
	/* C99 loop */
	{
		int i2;
		for (i2 = 0; (i2 < 2); i2 = (i2 + 1)) {
			dsp->fRec2[i2] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i3;
		for (i3 = 0; (i3 < 2); i3 = (i3 + 1)) {
			dsp->fRec1[i3] = 0.f;

		}

	}
	dsp->fConst6 = tan((171.297f / (float)dsp->iConst0));
	dsp->fConst7 = (1.f / dsp->fConst6);
	dsp->fConst8 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst6))));
	/* C99 loop */
	{
		int i4;
		for (i4 = 0; (i4 < 3); i4 = (i4 + 1)) {
			dsp->fRec4[i4] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i5;
		for (i5 = 0; (i5 < 3); i5 = (i5 + 1)) {
			dsp->fRec7[i5] = 0.f;

		}

	}
	dsp->fConst9 = (0.f - dsp->fConst7);
	/* C99 loop */
	{
		int i6;
		for (i6 = 0; (i6 < 2); i6 = (i6 + 1)) {
			dsp->fRec6[i6] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i7;
		for (i7 = 0; (i7 < 2); i7 = (i7 + 1)) {
			dsp->fRec5[i7] = 0.f;

		}

	}
	dsp->fConst10 = tan((252.975f / (float)dsp->iConst0));
	dsp->fConst11 = (1.f / dsp->fConst10);
	dsp->fConst12 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst10))));
	/* C99 loop */
	{
		int i8;
		for (i8 = 0; (i8 < 3); i8 = (i8 + 1)) {
			dsp->fRec8[i8] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i9;
		for (i9 = 0; (i9 < 3); i9 = (i9 + 1)) {
			dsp->fRec11[i9] = 0.f;

		}

	}
	dsp->fConst13 = (0.f - dsp->fConst11);
	/* C99 loop */
	{
		int i10;
		for (i10 = 0; (i10 < 2); i10 = (i10 + 1)) {
			dsp->fRec10[i10] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i11;
		for (i11 = 0; (i11 < 2); i11 = (i11 + 1)) {
			dsp->fRec9[i11] = 0.f;

		}

	}
	dsp->fConst14 = tan((373.6f / (float)dsp->iConst0));
	dsp->fConst15 = (1.f / dsp->fConst14);
	dsp->fConst16 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst14))));
	/* C99 loop */
	{
		int i12;
		for (i12 = 0; (i12 < 3); i12 = (i12 + 1)) {
			dsp->fRec12[i12] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i13;
		for (i13 = 0; (i13 < 3); i13 = (i13 + 1)) {
			dsp->fRec15[i13] = 0.f;

		}

	}
	dsp->fConst17 = (0.f - dsp->fConst15);
	/* C99 loop */
	{
		int i14;
		for (i14 = 0; (i14 < 2); i14 = (i14 + 1)) {
			dsp->fRec14[i14] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i15;
		for (i15 = 0; (i15 < 2); i15 = (i15 + 1)) {
			dsp->fRec13[i15] = 0.f;

		}

	}
	dsp->fConst18 = tan((551.743f / (float)dsp->iConst0));
	dsp->fConst19 = (1.f / dsp->fConst18);
	dsp->fConst20 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst18))));
	/* C99 loop */
	{
		int i16;
		for (i16 = 0; (i16 < 3); i16 = (i16 + 1)) {
			dsp->fRec16[i16] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i17;
		for (i17 = 0; (i17 < 3); i17 = (i17 + 1)) {
			dsp->fRec19[i17] = 0.f;

		}

	}
	dsp->fConst21 = (0.f - dsp->fConst19);
	/* C99 loop */
	{
		int i18;
		for (i18 = 0; (i18 < 2); i18 = (i18 + 1)) {
			dsp->fRec18[i18] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i19;
		for (i19 = 0; (i19 < 2); i19 = (i19 + 1)) {
			dsp->fRec17[i19] = 0.f;

		}

	}
	dsp->fConst22 = tan((814.828f / (float)dsp->iConst0));
	dsp->fConst23 = (1.f / dsp->fConst22);
	dsp->fConst24 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst22))));
	/* C99 loop */
	{
		int i20;
		for (i20 = 0; (i20 < 3); i20 = (i20 + 1)) {
			dsp->fRec20[i20] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i21;
		for (i21 = 0; (i21 < 3); i21 = (i21 + 1)) {
			dsp->fRec23[i21] = 0.f;

		}

	}
	dsp->fConst25 = (0.f - dsp->fConst23);
	/* C99 loop */
	{
		int i22;
		for (i22 = 0; (i22 < 2); i22 = (i22 + 1)) {
			dsp->fRec22[i22] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i23;
		for (i23 = 0; (i23 < 2); i23 = (i23 + 1)) {
			dsp->fRec21[i23] = 0.f;

		}

	}
	dsp->fConst26 = tan((1203.36f / (float)dsp->iConst0));
	dsp->fConst27 = (1.f / dsp->fConst26);
	dsp->fConst28 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst26))));
	/* C99 loop */
	{
		int i24;
		for (i24 = 0; (i24 < 3); i24 = (i24 + 1)) {
			dsp->fRec24[i24] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i25;
		for (i25 = 0; (i25 < 3); i25 = (i25 + 1)) {
			dsp->fRec27[i25] = 0.f;

		}

	}
	dsp->fConst29 = (0.f - dsp->fConst27);
	/* C99 loop */
	{
		int i26;
		for (i26 = 0; (i26 < 2); i26 = (i26 + 1)) {
			dsp->fRec26[i26] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i27;
		for (i27 = 0; (i27 < 2); i27 = (i27 + 1)) {
			dsp->fRec25[i27] = 0.f;

		}

	}
	dsp->fConst30 = tan((1777.15f / (float)dsp->iConst0));
	dsp->fConst31 = (1.f / dsp->fConst30);
	dsp->fConst32 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst30))));
	/* C99 loop */
	{
		int i28;
		for (i28 = 0; (i28 < 3); i28 = (i28 + 1)) {
			dsp->fRec28[i28] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i29;
		for (i29 = 0; (i29 < 3); i29 = (i29 + 1)) {
			dsp->fRec31[i29] = 0.f;

		}

	}
	dsp->fConst33 = (0.f - dsp->fConst31);
	/* C99 loop */
	{
		int i30;
		for (i30 = 0; (i30 < 2); i30 = (i30 + 1)) {
			dsp->fRec30[i30] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i31;
		for (i31 = 0; (i31 < 2); i31 = (i31 + 1)) {
			dsp->fRec29[i31] = 0.f;

		}

	}
	dsp->fConst34 = tan((2624.55f / (float)dsp->iConst0));
	dsp->fConst35 = (1.f / dsp->fConst34);
	dsp->fConst36 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst34))));
	/* C99 loop */
	{
		int i32;
		for (i32 = 0; (i32 < 3); i32 = (i32 + 1)) {
			dsp->fRec32[i32] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i33;
		for (i33 = 0; (i33 < 3); i33 = (i33 + 1)) {
			dsp->fRec35[i33] = 0.f;

		}

	}
	dsp->fConst37 = (0.f - dsp->fConst35);
	/* C99 loop */
	{
		int i34;
		for (i34 = 0; (i34 < 2); i34 = (i34 + 1)) {
			dsp->fRec34[i34] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i35;
		for (i35 = 0; (i35 < 2); i35 = (i35 + 1)) {
			dsp->fRec33[i35] = 0.f;

		}

	}
	dsp->fConst38 = tan((3876.f / (float)dsp->iConst0));
	dsp->fConst39 = (1.f / dsp->fConst38);
	dsp->fConst40 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst38))));
	/* C99 loop */
	{
		int i36;
		for (i36 = 0; (i36 < 3); i36 = (i36 + 1)) {
			dsp->fRec36[i36] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i37;
		for (i37 = 0; (i37 < 3); i37 = (i37 + 1)) {
			dsp->fRec39[i37] = 0.f;

		}

	}
	dsp->fConst41 = (0.f - dsp->fConst39);
	/* C99 loop */
	{
		int i38;
		for (i38 = 0; (i38 < 2); i38 = (i38 + 1)) {
			dsp->fRec38[i38] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i39;
		for (i39 = 0; (i39 < 2); i39 = (i39 + 1)) {
			dsp->fRec37[i39] = 0.f;

		}

	}
	dsp->fConst42 = tan((5724.18f / (float)dsp->iConst0));
	dsp->fConst43 = (1.f / dsp->fConst42);
	dsp->fConst44 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst42))));
	/* C99 loop */
	{
		int i40;
		for (i40 = 0; (i40 < 3); i40 = (i40 + 1)) {
			dsp->fRec40[i40] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i41;
		for (i41 = 0; (i41 < 3); i41 = (i41 + 1)) {
			dsp->fRec43[i41] = 0.f;

		}

	}
	dsp->fConst45 = (0.f - dsp->fConst43);
	/* C99 loop */
	{
		int i42;
		for (i42 = 0; (i42 < 2); i42 = (i42 + 1)) {
			dsp->fRec42[i42] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i43;
		for (i43 = 0; (i43 < 2); i43 = (i43 + 1)) {
			dsp->fRec41[i43] = 0.f;

		}

	}
	dsp->fConst46 = tan((8453.61f / (float)dsp->iConst0));
	dsp->fConst47 = (1.f / dsp->fConst46);
	dsp->fConst48 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst46))));
	/* C99 loop */
	{
		int i44;
		for (i44 = 0; (i44 < 3); i44 = (i44 + 1)) {
			dsp->fRec44[i44] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i45;
		for (i45 = 0; (i45 < 3); i45 = (i45 + 1)) {
			dsp->fRec47[i45] = 0.f;

		}

	}
	dsp->fConst49 = (0.f - dsp->fConst47);
	/* C99 loop */
	{
		int i46;
		for (i46 = 0; (i46 < 2); i46 = (i46 + 1)) {
			dsp->fRec46[i46] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i47;
		for (i47 = 0; (i47 < 2); i47 = (i47 + 1)) {
			dsp->fRec45[i47] = 0.f;

		}

	}
	dsp->fConst50 = tan((12484.5f / (float)dsp->iConst0));
	dsp->fConst51 = (1.f / dsp->fConst50);
	dsp->fConst52 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst50))));
	/* C99 loop */
	{
		int i48;
		for (i48 = 0; (i48 < 3); i48 = (i48 + 1)) {
			dsp->fRec48[i48] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i49;
		for (i49 = 0; (i49 < 3); i49 = (i49 + 1)) {
			dsp->fRec51[i49] = 0.f;

		}

	}
	dsp->fConst53 = (0.f - dsp->fConst51);
	/* C99 loop */
	{
		int i50;
		for (i50 = 0; (i50 < 2); i50 = (i50 + 1)) {
			dsp->fRec50[i50] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i51;
		for (i51 = 0; (i51 < 2); i51 = (i51 + 1)) {
			dsp->fRec49[i51] = 0.f;

		}

	}
	dsp->fConst54 = tan((18437.5f / (float)dsp->iConst0));
	dsp->fConst55 = (1.f / dsp->fConst54);
	dsp->fConst56 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst54))));
	/* C99 loop */
	{
		int i52;
		for (i52 = 0; (i52 < 3); i52 = (i52 + 1)) {
			dsp->fRec52[i52] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i53;
		for (i53 = 0; (i53 < 3); i53 = (i53 + 1)) {
			dsp->fRec55[i53] = 0.f;

		}

	}
	dsp->fConst57 = (0.f - dsp->fConst55);
	/* C99 loop */
	{
		int i54;
		for (i54 = 0; (i54 < 2); i54 = (i54 + 1)) {
			dsp->fRec54[i54] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i55;
		for (i55 = 0; (i55 < 2); i55 = (i55 + 1)) {
			dsp->fRec53[i55] = 0.f;

		}

	}
	dsp->fConst58 = tan((27228.9f / (float)dsp->iConst0));
	dsp->fConst59 = (1.f / dsp->fConst58);
	dsp->fConst60 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst58))));
	/* C99 loop */
	{
		int i56;
		for (i56 = 0; (i56 < 3); i56 = (i56 + 1)) {
			dsp->fRec56[i56] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i57;
		for (i57 = 0; (i57 < 3); i57 = (i57 + 1)) {
			dsp->fRec59[i57] = 0.f;

		}

	}
	dsp->fConst61 = (0.f - dsp->fConst59);
	/* C99 loop */
	{
		int i58;
		for (i58 = 0; (i58 < 2); i58 = (i58 + 1)) {
			dsp->fRec58[i58] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i59;
		for (i59 = 0; (i59 < 2); i59 = (i59 + 1)) {
			dsp->fRec57[i59] = 0.f;

		}

	}
	dsp->fConst62 = tan((40212.4f / (float)dsp->iConst0));
	dsp->fConst63 = (1.f / dsp->fConst62);
	dsp->fConst64 = (2.f * (1.f - (1.f / faustpower2_f(dsp->fConst62))));
	/* C99 loop */
	{
		int i60;
		for (i60 = 0; (i60 < 3); i60 = (i60 + 1)) {
			dsp->fRec60[i60] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i61;
		for (i61 = 0; (i61 < 3); i61 = (i61 + 1)) {
			dsp->fRec63[i61] = 0.f;

		}

	}
	dsp->fConst65 = (0.f - dsp->fConst63);
	/* C99 loop */
	{
		int i62;
		for (i62 = 0; (i62 < 2); i62 = (i62 + 1)) {
			dsp->fRec62[i62] = 0.f;

		}

	}
	/* C99 loop */
	{
		int i63;
		for (i63 = 0; (i63 < 2); i63 = (i63 + 1)) {
			dsp->fRec61[i63] = 0.f;

		}

	}

}

static void initvocoder(vocoder* dsp, int samplingFreq) {
	instanceInitvocoder(dsp, samplingFreq);
}

static void buildUserInterfacevocoder(vocoder* dsp, UIGlue* interface) {
	interface->addHorizontalSlider(interface->uiInterface, "atk", &dsp->fHslider1, 0.01f, 0.0001f, 0.5f, 1e-05f);
	interface->addHorizontalSlider(interface->uiInterface, "rel", &dsp->fHslider2, 0.01f, 0.0001f, 0.5f, 1e-05f);
	interface->addHorizontalSlider(interface->uiInterface, "bwratio", &dsp->fHslider0, 0.5f, 0.1f, 2.f, 0.001f);
}

static void computevocoder(vocoder* dsp, int count, FAUSTFLOAT** inputs, FAUSTFLOAT** outputs) {
	FAUSTFLOAT* input0 = inputs[0];
	FAUSTFLOAT* input1 = inputs[1];
	FAUSTFLOAT* output0 = outputs[0];
	float fSlow0 = (float)dsp->fHslider0;
	float fSlow1 = (0.645744f * fSlow0);
	float fSlow2 = (1.f / (1.f + (dsp->fConst2 * (fSlow1 + dsp->fConst2))));
	float fSlow3 = (1.f + (dsp->fConst2 * (dsp->fConst2 - fSlow1)));
	float fSlow4 = exp((0.f - (dsp->fConst5 / (float)dsp->fHslider1)));
	float fSlow5 = exp((0.f - (dsp->fConst5 / (float)dsp->fHslider2)));
	float fSlow6 = (0.645744f * fSlow0);
	float fSlow7 = (1.f / (1.f + (dsp->fConst7 * (fSlow6 + dsp->fConst7))));
	float fSlow8 = (1.f + (dsp->fConst7 * (dsp->fConst7 - fSlow6)));
	float fSlow9 = (1.f / (1.f + (dsp->fConst11 * (fSlow1 + dsp->fConst11))));
	float fSlow10 = (1.f + (dsp->fConst11 * (dsp->fConst11 - fSlow1)));
	float fSlow11 = (1.f / (1.f + (dsp->fConst15 * (fSlow6 + dsp->fConst15))));
	float fSlow12 = (1.f + (dsp->fConst15 * (dsp->fConst15 - fSlow6)));
	float fSlow13 = (0.645744f * fSlow0);
	float fSlow14 = (1.f / (1.f + (dsp->fConst19 * (fSlow13 + dsp->fConst19))));
	float fSlow15 = (1.f + (dsp->fConst19 * (dsp->fConst19 - fSlow13)));
	float fSlow16 = (1.f / (1.f + (dsp->fConst23 * (fSlow1 + dsp->fConst23))));
	float fSlow17 = (1.f + (dsp->fConst23 * (dsp->fConst23 - fSlow1)));
	float fSlow18 = (0.645744f * fSlow0);
	float fSlow19 = (1.f / (1.f + (dsp->fConst27 * (fSlow18 + dsp->fConst27))));
	float fSlow20 = (1.f + (dsp->fConst27 * (dsp->fConst27 - fSlow18)));
	float fSlow21 = (1.f / (1.f + (dsp->fConst31 * (fSlow13 + dsp->fConst31))));
	float fSlow22 = (1.f + (dsp->fConst31 * (dsp->fConst31 - fSlow13)));
	float fSlow23 = (0.645744f * fSlow0);
	float fSlow24 = (1.f / (1.f + (dsp->fConst35 * (fSlow23 + dsp->fConst35))));
	float fSlow25 = (1.f + (dsp->fConst35 * (dsp->fConst35 - fSlow23)));
	float fSlow26 = (1.f / (1.f + (dsp->fConst39 * (fSlow6 + dsp->fConst39))));
	float fSlow27 = (1.f + (dsp->fConst39 * (dsp->fConst39 - fSlow6)));
	float fSlow28 = (1.f / (1.f + (dsp->fConst43 * (fSlow6 + dsp->fConst43))));
	float fSlow29 = (1.f + (dsp->fConst43 * (dsp->fConst43 - fSlow6)));
	float fSlow30 = (1.f / (1.f + (dsp->fConst47 * (fSlow1 + dsp->fConst47))));
	float fSlow31 = (1.f + (dsp->fConst47 * (dsp->fConst47 - fSlow1)));
	float fSlow32 = (1.f / (1.f + (dsp->fConst51 * (fSlow13 + dsp->fConst51))));
	float fSlow33 = (1.f + (dsp->fConst51 * (dsp->fConst51 - fSlow13)));
	float fSlow34 = (1.f / (1.f + (dsp->fConst55 * (fSlow1 + dsp->fConst55))));
	float fSlow35 = (1.f + (dsp->fConst55 * (dsp->fConst55 - fSlow1)));
	float fSlow36 = (1.f / (1.f + (dsp->fConst59 * (fSlow13 + dsp->fConst59))));
	float fSlow37 = (1.f + (dsp->fConst59 * (dsp->fConst59 - fSlow13)));
	float fSlow38 = (1.f / (1.f + (dsp->fConst63 * (fSlow6 + dsp->fConst63))));
	float fSlow39 = (1.f + (dsp->fConst63 * (dsp->fConst63 - fSlow6)));
	/* C99 loop */
	{
		int i;
		for (i = 0; (i < count); i = (i + 1)) {
			float fTemp0 = (float)input1[i];
			dsp->fRec0[0] = (fTemp0 - (fSlow2 * ((fSlow3 * dsp->fRec0[2]) + (dsp->fConst3 * dsp->fRec0[1]))));
			float fTemp1 = (float)input0[i];
			dsp->fRec3[0] = (fTemp1 - (fSlow2 * ((fSlow3 * dsp->fRec3[2]) + (dsp->fConst3 * dsp->fRec3[1]))));
			float fTemp2 = fabs((fSlow2 * ((dsp->fConst2 * dsp->fRec3[0]) + (dsp->fConst4 * dsp->fRec3[2]))));
			float fTemp3 = ((dsp->fRec1[1] > fTemp2)?fSlow5:fSlow4);
			dsp->fRec2[0] = ((dsp->fRec2[1] * fTemp3) + (fTemp2 * (1.f - fTemp3)));
			dsp->fRec1[0] = dsp->fRec2[0];
			dsp->fRec4[0] = (fTemp0 - (fSlow7 * ((fSlow8 * dsp->fRec4[2]) + (dsp->fConst8 * dsp->fRec4[1]))));
			dsp->fRec7[0] = (fTemp1 - (fSlow7 * ((fSlow8 * dsp->fRec7[2]) + (dsp->fConst8 * dsp->fRec7[1]))));
			float fTemp4 = fabs((fSlow7 * ((dsp->fConst7 * dsp->fRec7[0]) + (dsp->fConst9 * dsp->fRec7[2]))));
			float fTemp5 = ((dsp->fRec5[1] > fTemp4)?fSlow5:fSlow4);
			dsp->fRec6[0] = ((dsp->fRec6[1] * fTemp5) + (fTemp4 * (1.f - fTemp5)));
			dsp->fRec5[0] = dsp->fRec6[0];
			dsp->fRec8[0] = (fTemp0 - (fSlow9 * ((fSlow10 * dsp->fRec8[2]) + (dsp->fConst12 * dsp->fRec8[1]))));
			dsp->fRec11[0] = (fTemp1 - (fSlow9 * ((fSlow10 * dsp->fRec11[2]) + (dsp->fConst12 * dsp->fRec11[1]))));
			float fTemp6 = fabs((fSlow9 * ((dsp->fConst11 * dsp->fRec11[0]) + (dsp->fConst13 * dsp->fRec11[2]))));
			float fTemp7 = ((dsp->fRec9[1] > fTemp6)?fSlow5:fSlow4);
			dsp->fRec10[0] = ((dsp->fRec10[1] * fTemp7) + (fTemp6 * (1.f - fTemp7)));
			dsp->fRec9[0] = dsp->fRec10[0];
			dsp->fRec12[0] = (fTemp0 - (fSlow11 * ((fSlow12 * dsp->fRec12[2]) + (dsp->fConst16 * dsp->fRec12[1]))));
			dsp->fRec15[0] = (fTemp1 - (fSlow11 * ((fSlow12 * dsp->fRec15[2]) + (dsp->fConst16 * dsp->fRec15[1]))));
			float fTemp8 = fabs((fSlow11 * ((dsp->fConst15 * dsp->fRec15[0]) + (dsp->fConst17 * dsp->fRec15[2]))));
			float fTemp9 = ((dsp->fRec13[1] > fTemp8)?fSlow5:fSlow4);
			dsp->fRec14[0] = ((dsp->fRec14[1] * fTemp9) + (fTemp8 * (1.f - fTemp9)));
			dsp->fRec13[0] = dsp->fRec14[0];
			dsp->fRec16[0] = (fTemp0 - (fSlow14 * ((fSlow15 * dsp->fRec16[2]) + (dsp->fConst20 * dsp->fRec16[1]))));
			dsp->fRec19[0] = (fTemp1 - (fSlow14 * ((fSlow15 * dsp->fRec19[2]) + (dsp->fConst20 * dsp->fRec19[1]))));
			float fTemp10 = fabs((fSlow14 * ((dsp->fConst19 * dsp->fRec19[0]) + (dsp->fConst21 * dsp->fRec19[2]))));
			float fTemp11 = ((dsp->fRec17[1] > fTemp10)?fSlow5:fSlow4);
			dsp->fRec18[0] = ((dsp->fRec18[1] * fTemp11) + (fTemp10 * (1.f - fTemp11)));
			dsp->fRec17[0] = dsp->fRec18[0];
			dsp->fRec20[0] = (fTemp0 - (fSlow16 * ((fSlow17 * dsp->fRec20[2]) + (dsp->fConst24 * dsp->fRec20[1]))));
			dsp->fRec23[0] = (fTemp1 - (fSlow16 * ((fSlow17 * dsp->fRec23[2]) + (dsp->fConst24 * dsp->fRec23[1]))));
			float fTemp12 = fabs((fSlow16 * ((dsp->fConst23 * dsp->fRec23[0]) + (dsp->fConst25 * dsp->fRec23[2]))));
			float fTemp13 = ((dsp->fRec21[1] > fTemp12)?fSlow5:fSlow4);
			dsp->fRec22[0] = ((dsp->fRec22[1] * fTemp13) + (fTemp12 * (1.f - fTemp13)));
			dsp->fRec21[0] = dsp->fRec22[0];
			dsp->fRec24[0] = (fTemp0 - (fSlow19 * ((fSlow20 * dsp->fRec24[2]) + (dsp->fConst28 * dsp->fRec24[1]))));
			dsp->fRec27[0] = (fTemp1 - (fSlow19 * ((fSlow20 * dsp->fRec27[2]) + (dsp->fConst28 * dsp->fRec27[1]))));
			float fTemp14 = fabs((fSlow19 * ((dsp->fConst27 * dsp->fRec27[0]) + (dsp->fConst29 * dsp->fRec27[2]))));
			float fTemp15 = ((dsp->fRec25[1] > fTemp14)?fSlow5:fSlow4);
			dsp->fRec26[0] = ((dsp->fRec26[1] * fTemp15) + (fTemp14 * (1.f - fTemp15)));
			dsp->fRec25[0] = dsp->fRec26[0];
			dsp->fRec28[0] = (fTemp0 - (fSlow21 * ((fSlow22 * dsp->fRec28[2]) + (dsp->fConst32 * dsp->fRec28[1]))));
			dsp->fRec31[0] = (fTemp1 - (fSlow21 * ((fSlow22 * dsp->fRec31[2]) + (dsp->fConst32 * dsp->fRec31[1]))));
			float fTemp16 = fabs((fSlow21 * ((dsp->fConst31 * dsp->fRec31[0]) + (dsp->fConst33 * dsp->fRec31[2]))));
			float fTemp17 = ((dsp->fRec29[1] > fTemp16)?fSlow5:fSlow4);
			dsp->fRec30[0] = ((dsp->fRec30[1] * fTemp17) + (fTemp16 * (1.f - fTemp17)));
			dsp->fRec29[0] = dsp->fRec30[0];
			dsp->fRec32[0] = (fTemp0 - (fSlow24 * ((fSlow25 * dsp->fRec32[2]) + (dsp->fConst36 * dsp->fRec32[1]))));
			dsp->fRec35[0] = (fTemp1 - (fSlow24 * ((fSlow25 * dsp->fRec35[2]) + (dsp->fConst36 * dsp->fRec35[1]))));
			float fTemp18 = fabs((fSlow24 * ((dsp->fConst35 * dsp->fRec35[0]) + (dsp->fConst37 * dsp->fRec35[2]))));
			float fTemp19 = ((dsp->fRec33[1] > fTemp18)?fSlow5:fSlow4);
			dsp->fRec34[0] = ((dsp->fRec34[1] * fTemp19) + (fTemp18 * (1.f - fTemp19)));
			dsp->fRec33[0] = dsp->fRec34[0];
			dsp->fRec36[0] = (fTemp0 - (fSlow26 * ((fSlow27 * dsp->fRec36[2]) + (dsp->fConst40 * dsp->fRec36[1]))));
			dsp->fRec39[0] = (fTemp1 - (fSlow26 * ((fSlow27 * dsp->fRec39[2]) + (dsp->fConst40 * dsp->fRec39[1]))));
			float fTemp20 = fabs((fSlow26 * ((dsp->fConst39 * dsp->fRec39[0]) + (dsp->fConst41 * dsp->fRec39[2]))));
			float fTemp21 = ((dsp->fRec37[1] > fTemp20)?fSlow5:fSlow4);
			dsp->fRec38[0] = ((dsp->fRec38[1] * fTemp21) + (fTemp20 * (1.f - fTemp21)));
			dsp->fRec37[0] = dsp->fRec38[0];
			dsp->fRec40[0] = (fTemp0 - (fSlow28 * ((fSlow29 * dsp->fRec40[2]) + (dsp->fConst44 * dsp->fRec40[1]))));
			dsp->fRec43[0] = (fTemp1 - (fSlow28 * ((fSlow29 * dsp->fRec43[2]) + (dsp->fConst44 * dsp->fRec43[1]))));
			float fTemp22 = fabs((fSlow28 * ((dsp->fConst43 * dsp->fRec43[0]) + (dsp->fConst45 * dsp->fRec43[2]))));
			float fTemp23 = ((dsp->fRec41[1] > fTemp22)?fSlow5:fSlow4);
			dsp->fRec42[0] = ((dsp->fRec42[1] * fTemp23) + (fTemp22 * (1.f - fTemp23)));
			dsp->fRec41[0] = dsp->fRec42[0];
			dsp->fRec44[0] = (fTemp0 - (fSlow30 * ((fSlow31 * dsp->fRec44[2]) + (dsp->fConst48 * dsp->fRec44[1]))));
			dsp->fRec47[0] = (fTemp1 - (fSlow30 * ((fSlow31 * dsp->fRec47[2]) + (dsp->fConst48 * dsp->fRec47[1]))));
			float fTemp24 = fabs((fSlow30 * ((dsp->fConst47 * dsp->fRec47[0]) + (dsp->fConst49 * dsp->fRec47[2]))));
			float fTemp25 = ((dsp->fRec45[1] > fTemp24)?fSlow5:fSlow4);
			dsp->fRec46[0] = ((dsp->fRec46[1] * fTemp25) + (fTemp24 * (1.f - fTemp25)));
			dsp->fRec45[0] = dsp->fRec46[0];
			dsp->fRec48[0] = (fTemp0 - (fSlow32 * ((fSlow33 * dsp->fRec48[2]) + (dsp->fConst52 * dsp->fRec48[1]))));
			dsp->fRec51[0] = (fTemp1 - (fSlow32 * ((fSlow33 * dsp->fRec51[2]) + (dsp->fConst52 * dsp->fRec51[1]))));
			float fTemp26 = fabs((fSlow32 * ((dsp->fConst51 * dsp->fRec51[0]) + (dsp->fConst53 * dsp->fRec51[2]))));
			float fTemp27 = ((dsp->fRec49[1] > fTemp26)?fSlow5:fSlow4);
			dsp->fRec50[0] = ((dsp->fRec50[1] * fTemp27) + (fTemp26 * (1.f - fTemp27)));
			dsp->fRec49[0] = dsp->fRec50[0];
			dsp->fRec52[0] = (fTemp0 - (fSlow34 * ((fSlow35 * dsp->fRec52[2]) + (dsp->fConst56 * dsp->fRec52[1]))));
			dsp->fRec55[0] = (fTemp1 - (fSlow34 * ((fSlow35 * dsp->fRec55[2]) + (dsp->fConst56 * dsp->fRec55[1]))));
			float fTemp28 = fabs((fSlow34 * ((dsp->fConst55 * dsp->fRec55[0]) + (dsp->fConst57 * dsp->fRec55[2]))));
			float fTemp29 = ((dsp->fRec53[1] > fTemp28)?fSlow5:fSlow4);
			dsp->fRec54[0] = ((dsp->fRec54[1] * fTemp29) + (fTemp28 * (1.f - fTemp29)));
			dsp->fRec53[0] = dsp->fRec54[0];
			dsp->fRec56[0] = (fTemp0 - (fSlow36 * ((fSlow37 * dsp->fRec56[2]) + (dsp->fConst60 * dsp->fRec56[1]))));
			dsp->fRec59[0] = (fTemp1 - (fSlow36 * ((fSlow37 * dsp->fRec59[2]) + (dsp->fConst60 * dsp->fRec59[1]))));
			float fTemp30 = fabs((fSlow36 * ((dsp->fConst59 * dsp->fRec59[0]) + (dsp->fConst61 * dsp->fRec59[2]))));
			float fTemp31 = ((dsp->fRec57[1] > fTemp30)?fSlow5:fSlow4);
			dsp->fRec58[0] = ((dsp->fRec58[1] * fTemp31) + (fTemp30 * (1.f - fTemp31)));
			dsp->fRec57[0] = dsp->fRec58[0];
			dsp->fRec60[0] = (fTemp0 - (fSlow38 * ((fSlow39 * dsp->fRec60[2]) + (dsp->fConst64 * dsp->fRec60[1]))));
			dsp->fRec63[0] = (fTemp1 - (fSlow38 * ((fSlow39 * dsp->fRec63[2]) + (dsp->fConst64 * dsp->fRec63[1]))));
			float fTemp32 = fabs((fSlow38 * ((dsp->fConst63 * dsp->fRec63[0]) + (dsp->fConst65 * dsp->fRec63[2]))));
			float fTemp33 = ((dsp->fRec61[1] > fTemp32)?fSlow5:fSlow4);
			dsp->fRec62[0] = ((dsp->fRec62[1] * fTemp33) + (fTemp32 * (1.f - fTemp33)));
			dsp->fRec61[0] = dsp->fRec62[0];
			output0[i] = (FAUSTFLOAT)((((((((((((((((fSlow2 * ((dsp->fRec0[2] * (0.f - (dsp->fConst2 * dsp->fRec1[0]))) + (dsp->fConst2 * (dsp->fRec0[0] * dsp->fRec1[0])))) + (fSlow7 * ((dsp->fRec4[2] * (0.f - (dsp->fConst7 * dsp->fRec5[0]))) + (dsp->fConst7 * (dsp->fRec4[0] * dsp->fRec5[0]))))) + (fSlow9 * ((dsp->fRec8[2] * (0.f - (dsp->fConst11 * dsp->fRec9[0]))) + (dsp->fConst11 * (dsp->fRec8[0] * dsp->fRec9[0]))))) + (fSlow11 * ((dsp->fRec12[2] * (0.f - (dsp->fConst15 * dsp->fRec13[0]))) + (dsp->fConst15 * (dsp->fRec12[0] * dsp->fRec13[0]))))) + (fSlow14 * ((dsp->fRec16[2] * (0.f - (dsp->fConst19 * dsp->fRec17[0]))) + (dsp->fConst19 * (dsp->fRec16[0] * dsp->fRec17[0]))))) + (fSlow16 * ((dsp->fRec20[2] * (0.f - (dsp->fConst23 * dsp->fRec21[0]))) + (dsp->fConst23 * (dsp->fRec20[0] * dsp->fRec21[0]))))) + (fSlow19 * ((dsp->fRec24[2] * (0.f - (dsp->fConst27 * dsp->fRec25[0]))) + (dsp->fConst27 * (dsp->fRec24[0] * dsp->fRec25[0]))))) + (fSlow21 * ((dsp->fRec28[2] * (0.f - (dsp->fConst31 * dsp->fRec29[0]))) + (dsp->fConst31 * (dsp->fRec28[0] * dsp->fRec29[0]))))) + (fSlow24 * ((dsp->fRec32[2] * (0.f - (dsp->fConst35 * dsp->fRec33[0]))) + (dsp->fConst35 * (dsp->fRec32[0] * dsp->fRec33[0]))))) + (fSlow26 * ((dsp->fRec36[2] * (0.f - (dsp->fConst39 * dsp->fRec37[0]))) + (dsp->fConst39 * (dsp->fRec36[0] * dsp->fRec37[0]))))) + (fSlow28 * ((dsp->fRec40[2] * (0.f - (dsp->fConst43 * dsp->fRec41[0]))) + (dsp->fConst43 * (dsp->fRec40[0] * dsp->fRec41[0]))))) + (fSlow30 * ((dsp->fRec44[2] * (0.f - (dsp->fConst47 * dsp->fRec45[0]))) + (dsp->fConst47 * (dsp->fRec44[0] * dsp->fRec45[0]))))) + (fSlow32 * ((dsp->fRec48[2] * (0.f - (dsp->fConst51 * dsp->fRec49[0]))) + (dsp->fConst51 * (dsp->fRec48[0] * dsp->fRec49[0]))))) + (fSlow34 * ((dsp->fRec52[2] * (0.f - (dsp->fConst55 * dsp->fRec53[0]))) + (dsp->fConst55 * (dsp->fRec52[0] * dsp->fRec53[0]))))) + (fSlow36 * ((dsp->fRec56[2] * (0.f - (dsp->fConst59 * dsp->fRec57[0]))) + (dsp->fConst59 * (dsp->fRec56[0] * dsp->fRec57[0]))))) + (fSlow38 * ((dsp->fRec60[2] * (0.f - (dsp->fConst63 * dsp->fRec61[0]))) + (dsp->fConst63 * (dsp->fRec60[0] * dsp->fRec61[0])))));
			dsp->fRec0[2] = dsp->fRec0[1];
			dsp->fRec0[1] = dsp->fRec0[0];
			dsp->fRec3[2] = dsp->fRec3[1];
			dsp->fRec3[1] = dsp->fRec3[0];
			dsp->fRec2[1] = dsp->fRec2[0];
			dsp->fRec1[1] = dsp->fRec1[0];
			dsp->fRec4[2] = dsp->fRec4[1];
			dsp->fRec4[1] = dsp->fRec4[0];
			dsp->fRec7[2] = dsp->fRec7[1];
			dsp->fRec7[1] = dsp->fRec7[0];
			dsp->fRec6[1] = dsp->fRec6[0];
			dsp->fRec5[1] = dsp->fRec5[0];
			dsp->fRec8[2] = dsp->fRec8[1];
			dsp->fRec8[1] = dsp->fRec8[0];
			dsp->fRec11[2] = dsp->fRec11[1];
			dsp->fRec11[1] = dsp->fRec11[0];
			dsp->fRec10[1] = dsp->fRec10[0];
			dsp->fRec9[1] = dsp->fRec9[0];
			dsp->fRec12[2] = dsp->fRec12[1];
			dsp->fRec12[1] = dsp->fRec12[0];
			dsp->fRec15[2] = dsp->fRec15[1];
			dsp->fRec15[1] = dsp->fRec15[0];
			dsp->fRec14[1] = dsp->fRec14[0];
			dsp->fRec13[1] = dsp->fRec13[0];
			dsp->fRec16[2] = dsp->fRec16[1];
			dsp->fRec16[1] = dsp->fRec16[0];
			dsp->fRec19[2] = dsp->fRec19[1];
			dsp->fRec19[1] = dsp->fRec19[0];
			dsp->fRec18[1] = dsp->fRec18[0];
			dsp->fRec17[1] = dsp->fRec17[0];
			dsp->fRec20[2] = dsp->fRec20[1];
			dsp->fRec20[1] = dsp->fRec20[0];
			dsp->fRec23[2] = dsp->fRec23[1];
			dsp->fRec23[1] = dsp->fRec23[0];
			dsp->fRec22[1] = dsp->fRec22[0];
			dsp->fRec21[1] = dsp->fRec21[0];
			dsp->fRec24[2] = dsp->fRec24[1];
			dsp->fRec24[1] = dsp->fRec24[0];
			dsp->fRec27[2] = dsp->fRec27[1];
			dsp->fRec27[1] = dsp->fRec27[0];
			dsp->fRec26[1] = dsp->fRec26[0];
			dsp->fRec25[1] = dsp->fRec25[0];
			dsp->fRec28[2] = dsp->fRec28[1];
			dsp->fRec28[1] = dsp->fRec28[0];
			dsp->fRec31[2] = dsp->fRec31[1];
			dsp->fRec31[1] = dsp->fRec31[0];
			dsp->fRec30[1] = dsp->fRec30[0];
			dsp->fRec29[1] = dsp->fRec29[0];
			dsp->fRec32[2] = dsp->fRec32[1];
			dsp->fRec32[1] = dsp->fRec32[0];
			dsp->fRec35[2] = dsp->fRec35[1];
			dsp->fRec35[1] = dsp->fRec35[0];
			dsp->fRec34[1] = dsp->fRec34[0];
			dsp->fRec33[1] = dsp->fRec33[0];
			dsp->fRec36[2] = dsp->fRec36[1];
			dsp->fRec36[1] = dsp->fRec36[0];
			dsp->fRec39[2] = dsp->fRec39[1];
			dsp->fRec39[1] = dsp->fRec39[0];
			dsp->fRec38[1] = dsp->fRec38[0];
			dsp->fRec37[1] = dsp->fRec37[0];
			dsp->fRec40[2] = dsp->fRec40[1];
			dsp->fRec40[1] = dsp->fRec40[0];
			dsp->fRec43[2] = dsp->fRec43[1];
			dsp->fRec43[1] = dsp->fRec43[0];
			dsp->fRec42[1] = dsp->fRec42[0];
			dsp->fRec41[1] = dsp->fRec41[0];
			dsp->fRec44[2] = dsp->fRec44[1];
			dsp->fRec44[1] = dsp->fRec44[0];
			dsp->fRec47[2] = dsp->fRec47[1];
			dsp->fRec47[1] = dsp->fRec47[0];
			dsp->fRec46[1] = dsp->fRec46[0];
			dsp->fRec45[1] = dsp->fRec45[0];
			dsp->fRec48[2] = dsp->fRec48[1];
			dsp->fRec48[1] = dsp->fRec48[0];
			dsp->fRec51[2] = dsp->fRec51[1];
			dsp->fRec51[1] = dsp->fRec51[0];
			dsp->fRec50[1] = dsp->fRec50[0];
			dsp->fRec49[1] = dsp->fRec49[0];
			dsp->fRec52[2] = dsp->fRec52[1];
			dsp->fRec52[1] = dsp->fRec52[0];
			dsp->fRec55[2] = dsp->fRec55[1];
			dsp->fRec55[1] = dsp->fRec55[0];
			dsp->fRec54[1] = dsp->fRec54[0];
			dsp->fRec53[1] = dsp->fRec53[0];
			dsp->fRec56[2] = dsp->fRec56[1];
			dsp->fRec56[1] = dsp->fRec56[0];
			dsp->fRec59[2] = dsp->fRec59[1];
			dsp->fRec59[1] = dsp->fRec59[0];
			dsp->fRec58[1] = dsp->fRec58[0];
			dsp->fRec57[1] = dsp->fRec57[0];
			dsp->fRec60[2] = dsp->fRec60[1];
			dsp->fRec60[1] = dsp->fRec60[0];
			dsp->fRec63[2] = dsp->fRec63[1];
			dsp->fRec63[1] = dsp->fRec63[0];
			dsp->fRec62[1] = dsp->fRec62[0];
			dsp->fRec61[1] = dsp->fRec61[0];

		}

	}

}

static void addHorizontalSlider(void* ui_interface, const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step)
{
    sp_vocoder *p = ui_interface;
    p->args[p->argpos] = zone;
    p->argpos++;
}

int sp_vocoder_create(sp_vocoder **p)
{
    *p = malloc(sizeof(sp_vocoder));
    return SP_OK;
}

int sp_vocoder_destroy(sp_vocoder **p)
{
    sp_vocoder *pp = *p;
    vocoder *dsp = pp->faust;
    deletevocoder (dsp);
    free(*p);
    return SP_OK;
}

int sp_vocoder_init(sp_data *sp, sp_vocoder *p)
{
    vocoder *dsp = newvocoder();
    UIGlue UI;
    p->argpos = 0;
    UI.addHorizontalSlider= addHorizontalSlider;
    UI.uiInterface = p;
    buildUserInterfacevocoder(dsp, &UI);
    initvocoder(dsp, sp->sr);


    p->atk = p->args[0];
    p->rel = p->args[1];
    p->bwratio = p->args[2];

    p->faust = dsp;
    return SP_OK;
}

int sp_vocoder_compute(sp_data *sp, sp_vocoder *p, SPFLOAT *source, SPFLOAT *excite, SPFLOAT *out)
{

    vocoder *dsp = p->faust;
    SPFLOAT *faust_out[] = {out};
    SPFLOAT *faust_in[] = {source, excite};
    computevocoder(dsp, 1, faust_in, faust_out);
    return SP_OK;
}
