#ifndef STK_CLARINET_H
#define STK_CLARINET_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "ReedTable.h"
#include "OneZero.h"
#include "Envelope.h"
#include "Noise.h"
#include "SineWave.h"

namespace stk {

/***************************************************/
/*! \class Clarinet
    \brief STK clarinet physical model class.

    This class implements a simple clarinet
    physical model, as discussed by Smith (1986),
    McIntyre, Schumacher, Woodhouse (1983), and
    others.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - Reed Stiffness = 2
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Clarinet : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  Clarinet( StkFloat lowestFrequency = 8.0 );

  //! Class destructor.
  ~Clarinet( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Apply breath pressure to instrument with given amplitude and rate of increase.
  void startBlowing( StkFloat amplitude, StkFloat rate );

  //! Decrease breath pressure with given rate of decrease.
  void stopBlowing( StkFloat rate );

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

  DelayL delayLine_;
  ReedTable reedTable_;
  OneZero filter_;
  Envelope envelope_;
  Noise noise_;
  SineWave vibrato_;

  StkFloat outputGain_;
  StkFloat noiseGain_;
  StkFloat vibratoGain_;
};

inline StkFloat Clarinet :: tick( unsigned int )
{
  StkFloat pressureDiff;
  StkFloat breathPressure;

  // Calculate the breath pressure (envelope + noise + vibrato)
  breathPressure = envelope_.tick(); 
  breathPressure += breathPressure * noiseGain_ * noise_.tick();
  breathPressure += breathPressure * vibratoGain_ * vibrato_.tick();

  // Perform commuted loss filtering.
  pressureDiff = -0.95 * filter_.tick( delayLine_.lastOut() );

  // Calculate pressure difference of reflected and mouthpiece pressures.
  pressureDiff = pressureDiff - breathPressure;

  // Perform non-linear scattering using pressure difference in reed function.
  lastFrame_[0] = delayLine_.tick(breathPressure + pressureDiff * reedTable_.tick(pressureDiff));

  // Apply output gain.
  lastFrame_[0] *= outputGain_;

  return lastFrame_[0];
}

inline StkFrames& Clarinet :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Clarinet::tick(): channel and StkFrames arguments are incompatible!";
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
