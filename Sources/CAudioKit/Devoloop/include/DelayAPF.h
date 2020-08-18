/*
        CDelayAPF: implements a delaying APF with a single coefficient g

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

// derived class of CDelay
class CDelayAPF : public CDelay {
public:
  // constructor/destructor
  CDelayAPF();
  ~CDelayAPF();

  // members
protected:
  float m_fAPF_g; // one g coefficient

public:
  // set our g value
  void setAPF_g(float fAPFg) { m_fAPF_g = fAPFg; }

  // overrides
  bool processAudio(float *pInput, float *pOutput);
};
