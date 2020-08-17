#include "pluginconstants.h"

// This file contains the object implementations for the objects declared in
// "pluginconstants.h"
//
// Note about Helper Objects: DO NOT MODIFY THESE OBJECTS. If you need to do so,
// create a derived class and modify it. These objects may be updated from time
// to time so they need to be left alone.

// CEnvelopeDetector Implementation
// ----------------------------------------------------------------
//
CEnvelopeDetector::CEnvelopeDetector(double samplerate) {
  m_fAttackTime_mSec = 0.0;
  m_fReleaseTime_mSec = 0.0;
  m_fAttackTime = 0.0;
  m_fReleaseTime = 0.0;
  m_fSampleRate = (float)samplerate;
  m_fEnvelope = 0.0;
  m_uDetectMode = 0;
  m_nSample = 0;
  m_bAnalogTC = false;
  m_bLogDetector = false;
}

CEnvelopeDetector::~CEnvelopeDetector() {}

void CEnvelopeDetector::prepareForPlay() {
  m_fEnvelope = 0.0;
  m_nSample = 0;
}

void CEnvelopeDetector::init(float samplerate, float attack_in_ms,
                             float release_in_ms, bool bAnalogTC, UINT uDetect,
                             bool bLogDetector) {
  m_fEnvelope = 0.0;
  m_fSampleRate = samplerate;
  m_bAnalogTC = bAnalogTC;
  m_fAttackTime_mSec = attack_in_ms;
  m_fReleaseTime_mSec = release_in_ms;
  m_uDetectMode = uDetect;
  m_bLogDetector = bLogDetector;

  // set themm_uDetectMode = uDetect;
  setAttackDuration(attack_in_ms);
  setReleaseDuration(release_in_ms);
}

void CEnvelopeDetector::setAttackDuration(float attack_in_ms) {
  m_fAttackTime_mSec = attack_in_ms;

  if (m_bAnalogTC)
    m_fAttackTime = expf(ANALOG_TC / (attack_in_ms * m_fSampleRate * 0.001f));
  else
    m_fAttackTime = expf(DIGITAL_TC / (attack_in_ms * m_fSampleRate * 0.001f));
}

void CEnvelopeDetector::setReleaseDuration(float release_in_ms) {
  m_fReleaseTime_mSec = release_in_ms;

  if (m_bAnalogTC)
    m_fReleaseTime = expf(ANALOG_TC / (release_in_ms * m_fSampleRate * 0.001f));
  else
    m_fReleaseTime =
        expf(DIGITAL_TC / (release_in_ms * m_fSampleRate * 0.001f));
}

void CEnvelopeDetector::setTCModeAnalog(bool bAnalogTC) {
  m_bAnalogTC = bAnalogTC;
  setAttackDuration(m_fAttackTime_mSec);
  setReleaseDuration(m_fReleaseTime_mSec);
}

float CEnvelopeDetector::detect(float fInput) {
  switch (m_uDetectMode) {
  case 0:
    fInput = fabsf(fInput);
    break;
  case 1:
    fInput = fabsf(fInput) * fabsf(fInput);
    break;
  case 2:
    fInput = powf((float)fabsf(fInput) * (float)fabsf(fInput), (float)0.5);
    break;
  default:
    fInput = (float)fabsf(fInput);
    break;
  }

  // float fOld = m_fEnvelope;
  if (fInput > m_fEnvelope)
    m_fEnvelope = m_fAttackTime * (m_fEnvelope - fInput) + fInput;
  else
    m_fEnvelope = m_fReleaseTime * (m_fEnvelope - fInput) + fInput;

  if (m_fEnvelope > 0.0 && m_fEnvelope < FLT_MIN_PLUS)
    m_fEnvelope = 0;
  if (m_fEnvelope < 0.0 && m_fEnvelope > FLT_MIN_MINUS)
    m_fEnvelope = 0;

  // bound them; can happen when using pre-detector gains of more than 1.0
  m_fEnvelope = min(m_fEnvelope, 1.0);
  m_fEnvelope = max(m_fEnvelope, 0.0);

  // 16-bit scaling!
  if (m_bLogDetector) {
    if (m_fEnvelope <= 0)
      return -96.0; // 16 bit noise floor

    return 20.0f * log10f(m_fEnvelope);
  }

  return m_fEnvelope;
}
