#pragma once

// includes for the project

// this #define enables the following constants form math.h
#define _MATH_DEFINES_DEFINED
/*
 #define M_E        2.71828182845904523536
 #define M_LOG2E    1.44269504088896340736
 #define M_LOG10E   0.434294481903251827651
 #define M_LN2      0.693147180559945309417
 #define M_LN10     2.30258509299404568402
 #define M_PI       3.14159265358979323846
 #define M_PI_2     1.57079632679489661923
 #define M_PI_4     0.785398163397448309616
 #define M_1_PI     0.318309886183790671538
 #define M_2_PI     0.636619772367581343076
 #define M_2_SQRTPI 1.12837916709551257390
 #define M_SQRT2    1.41421356237309504880
 #define M_SQRT1_2  0.707106781186547524401
 */

#include <math.h>
#include <stdlib.h>
#include <string.h>

// For WIN vs MacOS
// XCode requires these be defined for compatibility

typedef unsigned int UINT;
typedef unsigned long DWORD;
typedef unsigned char UCHAR;
typedef unsigned char BYTE;

const UINT DETECT_MODE_PEAK = 0;
const UINT DETECT_MODE_MS = 1;
const UINT DETECT_MODE_RMS = 2;
const UINT DETECT_MODE_NONE = 3;

// More #defines for MacOS/XCode
#ifndef max
#define max(a, b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
#define min(a, b) (((a) < (b)) ? (a) : (b))
#endif

#ifndef itoa
#define itoa(value, string, radix) sprintf(string, "%d", value)
#endif

#ifndef ltoa
#define ltoa(value, string, radix) sprintf(string, "%u", value)
#endif

// a few more constants from student suggestions
#define pi 3.1415926535897932384626433832795
#define sqrt2over2 0.707106781186547524401 // same as M_SQRT1_2

// constants for dealing with overflow or underflow
#define FLT_EPSILON_PLUS                                                       \
1.192092896e-07 /* smallest such that 1.0+FLT_EPSILON != 1.0 */
#define FLT_EPSILON_MINUS                                                      \
-1.192092896e-07 /* smallest such that 1.0-FLT_EPSILON != 1.0 */
#define FLT_MIN_PLUS 1.175494351e-38   /* min positive value */
#define FLT_MIN_MINUS -1.175494351e-38 /* min negative value */

// basic enums
enum { intData, floatData, doubleData, UINTData, nonData };
enum { JS_ONESHOT, JS_LOOP, JS_SUSTAIN, JS_LOOP_BACKANDFORTH };

// © by Mike Gazzaruso, 2014

/*
 Function:	lagrpol() implements n-order Lagrange Interpolation

 Inputs:		double* x	Pointer to an array containing
 the x-coordinates of the input values double* y	Pointer to an array
 containing the y-coordinates of the input values
 int n		The order of the
 interpolator, this is also the length of the x,y input arrays double xbar
 The x-coorinates whose y-value we want to interpolate

 Returns		The interpolated value y at xbar. xbar ideally is
 between the middle two values in the input array, but can be anywhere within
 the limits, which is needed for interpolating the first few or last few
 samples in a table with a fixed size.
 */
inline double lagrpol(double *x, double *y, int n, double xbar) {
    int i, j;
    double fx = 0.0;
    double l = 1.0;
    for (i = 0; i < n; i++) {
        l = 1.0;
        for (j = 0; j < n; j++) {
            if (j != i)
                l *= (xbar - x[j]) / (x[i] - x[j]);
        }
        fx += l * y[i];
    }
    return (fx);
}

inline float dLinTerp(float x1, float x2, float y1, float y2, float x) {
    float denom = x2 - x1;
    if (denom == 0)
        return y1; // should not ever happen

    // calculate decimal position of x
    float dx = (x - x1) / (x2 - x1);

    // use weighted sum method of interpolating
    float result = dx * y2 + (1 - dx) * y1;

    return result;
}

inline bool normalizeBuffer(double *pInputBuffer, UINT uBufferSize) {
    double fMax = 0;

    for (UINT j = 0; j < uBufferSize; j++) {
        if ((fabs(pInputBuffer[j])) > fMax)
            fMax = fabs(pInputBuffer[j]);
    }

    if (fMax > 0) {
        for (UINT j = 0; j < uBufferSize; j++)
            pInputBuffer[j] = pInputBuffer[j] / fMax;
    }

    return true;
}

const float DIGITAL_TC = -2.0;                                // log(1%)
const float ANALOG_TC = -0.43533393574791066201247090699309f; // (log(36.7%)
const float METER_UPDATE_INTERVAL_MSEC = 15.0;
const float METER_MIN_DB = -60.0;

class CEnvelopeDetector {
public:
    CEnvelopeDetector(double samplerate);
    ~CEnvelopeDetector();

    // Call the Init Function to initialize and setup all at once; this can be
    // called as many times as you want
    void init(float samplerate, float attack_in_ms, float release_in_ms,
              bool bAnalogTC, UINT uDetect, bool bLogDetector);

    // these functions allow you to change modes and attack/release one at a time
    // during realtime operation
    void setTCModeAnalog(bool bAnalogTC); // {m_bAnalogTC = bAnalogTC;}

    // THEN do these after init
    void setAttackDuration(float attack_in_ms);
    void setReleaseDuration(float release_in_ms);

    // Use these "codes"
    // DETECT PEAK   = 0
    // DETECT MS	 = 1
    // DETECT RMS	 = 2
    //
    void setDetectMode(UINT uDetect) { m_uDetectMode = uDetect; }

    void setSampleRate(float f) { m_fSampleRate = f; }

    void setLogDetect(bool b) { m_bLogDetector = b; }

    // call this to detect; it returns the peak ms or rms value at that instant
    float detect(float fInput);

    // call this from your prepareForPlay() function each time to reset the
    // detector
    void prepareForPlay();

protected:
    int m_nSample;
    float m_fAttackTime;
    float m_fReleaseTime;
    float m_fAttackTime_mSec;
    float m_fReleaseTime_mSec;
    float m_fSampleRate;
    float m_fEnvelope;
    UINT m_uDetectMode;
    bool m_bAnalogTC;
    bool m_bLogDetector;
};
