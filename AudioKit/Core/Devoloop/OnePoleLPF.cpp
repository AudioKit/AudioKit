#include "OnePoleLPF.h"

COnePoleLPF::COnePoleLPF() {
  m_fLPF_g = 0;
  m_fLPF_z1 = 0;
}

COnePoleLPF::~COnePoleLPF() {}

void COnePoleLPF::init() { m_fLPF_z1 = 0.0; }

bool COnePoleLPF::processAudio(float *pInput, float *pOutput) {
  // read the delay line to get w(n-D); call base class
  // read
  float yn_LPF = *pInput * (1.0f - m_fLPF_g) + m_fLPF_g * m_fLPF_z1;
  // float yn_LPF = *pInput*(m_fLPF_g) + (1.0 - m_fLPF_g)*m_fLPF_z1;

  // this just reverses the slider
  // float yn_LPF = *pInput*(m_fLPF_g) + (1.0 - m_fLPF_g)*m_fLPF_z1;

  // form fb & write
  m_fLPF_z1 = yn_LPF;

  *pOutput = yn_LPF;

  // all OK
  return true;
}
