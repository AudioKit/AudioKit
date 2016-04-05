#ifndef STK_STIFKARP_H
#define STK_STIFKARP_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "DelayA.h"
#include "OneZero.h"
#include "Noise.h"
#include "BiQuad.h"

namespace stk {

/***************************************************/
/*! \class StifKarp
    \brief STK plucked stiff string instrument.

    This class implements a simple plucked string
    algorithm (Karplus Strong) with enhancements
    (Jaffe-Smith, Smith, and others), including
    string stiffness and pluck position controls.
    The stiffness is modeled with allpass filters.

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.

    Control Change Numbers:
       - Pickup Position = 4
       - String Sustain = 11
       - String Stretch = 1

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class StifKarp : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  StifKarp( StkFloat lowestFrequency = 8.0 );

  //! Class destructor.
  ~StifKarp( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the stretch "factor" of the string (0.0 - 1.0).
  void setStretch( StkFloat stretch );

  //! Set the pluck or "excitation" position along the string (0.0 - 1.0).
  void setPickupPosition( StkFloat position );

  //! Set the base loop gain.
  /*!
    The actual loop gain is set according to the frequency.
    Because of high-frequency loop filter roll-off, higher
    frequency settings have greater loop gains.
  */
  void setBaseLoopGain( StkFloat aGain );

  //! Pluck the string with the given amplitude using the current frequency.
  void pluck( StkFloat amplitude );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

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

  DelayA  delayLine_;
  DelayL  combDelay_;
  OneZero filter_;
  Noise   noise_;
  BiQuad  biquad_[4];

  unsigned long length_;
  StkFloat loopGain_;
  StkFloat baseLoopGain_;
  StkFloat lastFrequency_;
  StkFloat lastLength_;
  StkFloat stretching_;
  StkFloat pluckAmplitude_;
  StkFloat pickupPosition_;

};

inline StkFloat StifKarp :: tick( unsigned int )
{
  StkFloat temp = delayLine_.lastOut() * loopGain_;

  // Calculate allpass stretching.
  for (int i=0; i<4; i++)
    temp = biquad_[i].tick(temp);

  // Moving average filter.
  temp = filter_.tick(temp);

  lastFrame_[0] = delayLine_.tick(temp);
  lastFrame_[0] = lastFrame_[0] - combDelay_.tick( lastFrame_[0] );
  return lastFrame_[0];
}

inline StkFrames& StifKarp :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "StifKarp::tick(): channel and StkFrames arguments are incompatible!";
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
