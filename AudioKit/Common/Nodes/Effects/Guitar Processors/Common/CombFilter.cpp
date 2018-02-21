#include "CombFilter.h"

CCombFilter::CCombFilter(void) : CDelay() { m_fComb_g = 0; }

CCombFilter::~CCombFilter() {}

bool CCombFilter::processAudio(float *pInput, float *pOutput) {
  // read the delay line to get w(n-D); call base class
  float yn = this->readDelay();

  if (m_nReadIndex == m_nWriteIndex)
    yn = 0;

  // form fb = x(n) + m_fComb_gy(n)
  float fb = *pInput + m_fComb_g * yn;

  // write delay line
  this->writeDelayAndInc(fb);

  // write the output sample (could be combined with above line)
  if (m_nReadIndex == m_nWriteIndex)
    yn = *pInput;

  *pOutput = yn;

  // all OK
  return true;
}
