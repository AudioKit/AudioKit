/*
        CCombFilter: implements a comb filter of length D with
                                 feedback gain m_fComb_g

        Can be used alone or as a base class.



*/

// Inherited Base Class functions:
/*
        void init(int nDelayLength);
        void resetDelay();
        void setDelay_mSec(float fmSec);
        void setOutputAttenuation_dB(float fAttendB);

        // NEED TO OVERRIDE
        bool processAudio(float *pInput, float *pOutput);
*/
#pragma once
#include "CDelay.h"

// derived class: CDelay does most of the work
class CCombFilter : public CDelay {
public:
  // constructor/destructor
  CCombFilter();
  ~CCombFilter();

  // members
protected:
  float m_fComb_g; // one coefficient

public:
  // set our g value directly
  void setComb_g(float fCombg) { m_fComb_g = fCombg; }

  // set gain using RT60 time
  void setComb_g_with_RTSixty(float fRT) {
    float fExponent = -3.0f * m_fDelayInSamples * (1.0f / m_nSampleRate);
    fRT /= 1000.0; // RT is in mSec!

    m_fComb_g = powf((float)10.0, fExponent / fRT);
  }

  // do some audio processing
  bool processAudio(float *pInput, float *pOutput);
};
