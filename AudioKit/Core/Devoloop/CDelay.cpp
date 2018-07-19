#include "CDelay.h"
#include "pluginconstants.h"

CDelay::CDelay() {
  m_pBuffer = NULL;

  m_fOutputAttenuation_dB = 0;
  m_fDelay_ms = 0.0;

  m_fOutputAttenuation = 0.0;
  m_fDelayInSamples = 0.0;
  m_nSampleRate = 0;

  resetDelay();
}

CDelay::~CDelay() {
  if (m_pBuffer)
    delete m_pBuffer;

  m_pBuffer = NULL;
}

void CDelay::init(int nDelayLength) {
  m_nBufferSize = nDelayLength;

  m_pBuffer = new float[m_nBufferSize];

  // flush buffer
  memset(m_pBuffer, 0, (unsigned)m_nBufferSize * sizeof(float));
}

void CDelay::resetDelay() {
  // flush buffer
  if (m_pBuffer)
    memset(m_pBuffer, 0, (unsigned)m_nBufferSize * sizeof(float));

  // init read/write indices
  m_nWriteIndex = 0; // reset the Write index to top
  m_nReadIndex = 0;  // reset the Write index to top

  cookVariables();
}

void CDelay::setDelay_mSec(float fmSec) {
  m_fDelay_ms = fmSec;
  cookVariables();
}

void CDelay::setOutputAttenuation_dB(float fAttendB) {
  m_fOutputAttenuation_dB = fAttendB;
  cookVariables();
}

void CDelay::cookVariables() {
  m_fOutputAttenuation =
      powf((float)10.0, (float)m_fOutputAttenuation_dB / (float)20.0);

  m_fDelayInSamples = m_fDelay_ms * (44100.0f / 1000.0f);

  // subtract to make read index
  m_nReadIndex = m_nWriteIndex - (int)m_fDelayInSamples;

  //  the check and wrap BACKWARDS if the index is negative
  if (m_nReadIndex < 0)
    m_nReadIndex += m_nBufferSize; // amount of wrap is Read + Length
}

void CDelay::writeDelayAndInc(float fDelayInput) {
  // write to the delay line
  m_pBuffer[m_nWriteIndex] = fDelayInput; // external feedback sample

  // incremnent the pointers and wrap if necessary
  m_nWriteIndex++;
  if (m_nWriteIndex >= m_nBufferSize)
    m_nWriteIndex = 0;

  m_nReadIndex++;
  if (m_nReadIndex >= m_nBufferSize)
    m_nReadIndex = 0;
}

float CDelay::readDelay() {
  // Read the output of the delay at m_nReadIndex
  float yn = m_pBuffer[m_nReadIndex];

  // Read the location ONE BEHIND yn at y(n-1)
  int nReadIndex_1 = m_nReadIndex - 1;
  if (nReadIndex_1 < 0)
    nReadIndex_1 = m_nBufferSize - 1; // m_nBufferSize-1 is last location

  // get y(n-1)
  float yn_1 = m_pBuffer[nReadIndex_1];

  // interpolate: (0, yn) and (1, yn_1) by the amount fracDelay
  float fFracDelay = m_fDelayInSamples - (int)m_fDelayInSamples;

  return dLinTerp(0, 1, yn, yn_1, fFracDelay); // interp frac between them
}

float CDelay::readDelayAt(float fmSec) {
  float fDelayInSamples = fmSec * ((float)m_nSampleRate) / 1000.0f;

  // subtract to make read index
  int nReadIndex = m_nWriteIndex - (int)fDelayInSamples;

  // Read the output of the delay at m_nReadIndex
  float yn = m_pBuffer[nReadIndex];

  // Read the location ONE BEHIND yn at y(n-1)
  int nReadIndex_1 = nReadIndex - 1;
  if (nReadIndex_1 < 0)
    nReadIndex_1 = m_nBufferSize - 1; // m_nBufferSize-1 is last location

  // get y(n-1)
  float yn_1 = m_pBuffer[nReadIndex_1];

  // interpolate: (0, yn) and (1, yn_1) by the amount fracDelay
  float fFracDelay = fDelayInSamples - (int)fDelayInSamples;

  return dLinTerp(0, 1, yn, yn_1, fFracDelay); // interp frac between them
}

bool CDelay::processAudio(float *pInput, float *pOutput) {
  // Read the Input
  float xn = *pInput;

  // read delayed output
  float yn = m_fDelayInSamples == 0 ? xn : readDelay();

  // write to the delay line
  writeDelayAndInc(xn);

  // output attenuation
  *pOutput = m_fOutputAttenuation * yn;

  return true; // all OK
}
