#include "DelayAPF.h"

CDelayAPF::CDelayAPF(void) : CDelay() { m_fAPF_g = 0; }

CDelayAPF::~CDelayAPF() {}

bool CDelayAPF::processAudio(float *pInput, float *pOutput) {
  // read the delay line to get w(n-D); call base class
  float fw_n_D = this->readDelay();

  // form w(n) = x(n) + gw(n-D)
  float fw_n = *pInput + m_fAPF_g * fw_n_D;

  // form y(n) = -gw(n) + w(n-D)
  float fy_n = -m_fAPF_g * fw_n + fw_n_D;

  // write delay line
  this->writeDelayAndInc(fw_n);

  // write the output sample (could be combined with above line)
  *pOutput = fy_n;

  // all OK
  return true;
}
