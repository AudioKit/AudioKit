#ifndef STK_PERCFLUT_H
#define STK_PERCFLUT_H

#include "FM.h"

namespace stk {

/***************************************************/
/*! \class PercFlut
    \brief STK percussive flute FM synthesis instrument.

    This class implements algorithm 4 of the TX81Z.

    \code
    Algorithm 4 is :   4->3--\
                          2-- + -->1-->Out
    \endcode

    Control Change Numbers:
       - Total Modulator Index = 2
       - Modulator Crossfade = 4
       - LFO Speed = 11
       - LFO Depth = 1
       - ADSR 2 & 4 Target = 128

    The basic Chowning/Stanford FM patent expired
    in 1995, but there exist follow-on patents,
    mostly assigned to Yamaha.  If you are of the
    type who should worry about this (making
    money) worry away.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class PercFlut : public FM {
public:
  //! Class constructor.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  PercFlut(void);

  //! Class destructor.
  ~PercFlut(void);

  //! Set instrument parameters for a particular frequency.
  void setFrequency(StkFloat frequency);

  //! Start a note with the given frequency and amplitude.
  void noteOn(StkFloat frequency, StkFloat amplitude);

  //! Compute and return one output sample.
  StkFloat tick(unsigned int channel = 0);

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames &tick(StkFrames &frames, unsigned int channel = 0);

protected:
};

inline StkFloat PercFlut ::tick(unsigned int) {
  StkFloat temp;

  temp = vibrato_.tick() * modDepth_ * 0.2;
  waves_[0]->setFrequency(baseFrequency_ * (1.0 + temp) * ratios_[0]);
  waves_[1]->setFrequency(baseFrequency_ * (1.0 + temp) * ratios_[1]);
  waves_[2]->setFrequency(baseFrequency_ * (1.0 + temp) * ratios_[2]);
  waves_[3]->setFrequency(baseFrequency_ * (1.0 + temp) * ratios_[3]);

  waves_[3]->addPhaseOffset(twozero_.lastOut());
  temp = gains_[3] * adsr_[3]->tick() * waves_[3]->tick();

  twozero_.tick(temp);
  waves_[2]->addPhaseOffset(temp);
  temp = (1.0 - (control2_ * 0.5)) * gains_[2] * adsr_[2]->tick() *
         waves_[2]->tick();

  temp += control2_ * 0.5 * gains_[1] * adsr_[1]->tick() * waves_[1]->tick();
  temp = temp * control1_;

  waves_[0]->addPhaseOffset(temp);
  temp = gains_[0] * adsr_[0]->tick() * waves_[0]->tick();

  lastFrame_[0] = temp * 0.5;
  return lastFrame_[0];
}

inline StkFrames &PercFlut ::tick(StkFrames &frames, unsigned int channel) {
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if (channel > frames.channels() - nChannels) {
    oStream_ << "PercFlut::tick(): channel and StkFrames arguments are "
                "incompatible!";
    handleError(StkError::FUNCTION_ARGUMENT);
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if (nChannels == 1) {
    for (unsigned int i = 0; i < frames.frames(); i++, samples += hop)
      *samples++ = tick();
  } else {
    for (unsigned int i = 0; i < frames.frames(); i++, samples += hop) {
      *samples++ = tick();
      for (j = 1; j < nChannels; j++)
        *samples++ = lastFrame_[j];
    }
  }

  return frames;
}

} // namespace stk

#endif
