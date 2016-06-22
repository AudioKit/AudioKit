#ifndef STK_FMVOICES_H
#define STK_FMVOICES_H

#include "FM.h"

namespace stk {

/***************************************************/
/*! \class FMVoices
    \brief STK singing FM synthesis instrument.

    This class implements 3 carriers and a common
    modulator, also referred to as algorithm 6 of
    the TX81Z.

    \code
    Algorithm 6 is :
                        /->1 -\
                     4-|-->2 - +-> Out
                        \->3 -/
    \endcode

    Control Change Numbers: 
       - Vowel = 2
       - Spectral Tilt = 4
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

class FMVoices : public FM
{
 public:
  //! Class constructor.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  FMVoices( void );

  //! Class destructor.
  ~FMVoices( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  void controlChange( int number, StkFloat value );

  //! Compute and return one output sample.
  StkFloat tick( unsigned int channel = 0 );

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

 protected:

  int currentVowel_;
  StkFloat tilt_[3];
  StkFloat mods_[3];
};

inline StkFloat FMVoices :: tick( unsigned int )
{
  StkFloat temp, temp2;

  temp = gains_[3] * adsr_[3]->tick() * waves_[3]->tick();
  temp2 = vibrato_.tick() * modDepth_ * 0.1;

  waves_[0]->setFrequency(baseFrequency_ * (1.0 + temp2) * ratios_[0]);
  waves_[1]->setFrequency(baseFrequency_ * (1.0 + temp2) * ratios_[1]);
  waves_[2]->setFrequency(baseFrequency_ * (1.0 + temp2) * ratios_[2]);
  waves_[3]->setFrequency(baseFrequency_ * (1.0 + temp2) * ratios_[3]);

  waves_[0]->addPhaseOffset(temp * mods_[0]);
  waves_[1]->addPhaseOffset(temp * mods_[1]);
  waves_[2]->addPhaseOffset(temp * mods_[2]);
  waves_[3]->addPhaseOffset( twozero_.lastOut() );
  twozero_.tick( temp );
  temp =  gains_[0] * tilt_[0] * adsr_[0]->tick() * waves_[0]->tick();
  temp += gains_[1] * tilt_[1] * adsr_[1]->tick() * waves_[1]->tick();
  temp += gains_[2] * tilt_[2] * adsr_[2]->tick() * waves_[2]->tick();

  lastFrame_[0] = temp * 0.33;
  return lastFrame_[0];
}

inline StkFrames& FMVoices :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "FMVoices::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if ( nChannels == 1 ) {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
      *samples++ = tick();
  }
  else {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
      *samples++ = tick();
      for ( j=1; j<nChannels; j++ )
        *samples++ = lastFrame_[j];
    }
  }

  return frames;
}

} // stk namespace

#endif
