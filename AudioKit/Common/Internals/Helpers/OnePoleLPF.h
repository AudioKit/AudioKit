#pragma once

class COnePoleLPF {
public:
  // constructor/Destructor
  COnePoleLPF();
  ~COnePoleLPF();

  // members
protected:
  float m_fLPF_g;  // one gain coefficient
  float m_fLPF_z1; // one delay

public:
  // set our one and only gain coefficient
  void setLPF_g(float fLPFg) { m_fLPF_g = fLPFg; }

  // function to init
  void init();

  // function to process audio
  bool processAudio(float *pInput, float *pOutput);
};
