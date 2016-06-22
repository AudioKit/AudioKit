#ifndef STK_FLUTE_H
#define STK_FLUTE_H

#include "Instrmnt.h"
#include "JetTable.h"
#include "DelayL.h"
#include "OnePole.h"
#include "PoleZero.h"
#include "Noise.h"
#include "ADSR.h"
#include "SineWave.h"

namespace stk {

/***************************************************/
/*! \class Flute
    \brief STK flute physical model class.

    This class implements a simple flute
    physical model, as discussed by Karjalainen,
    Smith, Waryznyk, etc.  The jet model uses
    a polynomial, a la Cook.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - Jet Delay = 2
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Breath Pressure = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Flute : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  /*!
    An StkError will be thrown if the rawwave path is incorrectly set.
  */
  Flute( StkFloat lowestFrequency );

  //! Class destructor.
  ~Flute( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the reflection coefficient for the jet delay (-1.0 - 1.0).
  void setJetReflection( StkFloat coefficient ) { jetReflection_ = coefficient; };

  //! Set the reflection coefficient for the air column delay (-1.0 - 1.0).
  void setEndReflection( StkFloat coefficient ) { endReflection_ = coefficient; };

  //! Set the length of the jet delay in terms of a ratio of jet delay to air column delay lengths.
  void setJetDelay( StkFloat aRatio );

  //! Apply breath velocity to instrument with given amplitude and rate of increase.
  void startBlowing( StkFloat amplitude, StkFloat rate );

  //! Decrease breath velocity with given rate of decrease.
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

  DelayL   jetDelay_;
  DelayL   boreDelay_;
  JetTable jetTable_;
  OnePole  filter_;
  PoleZero dcBlock_;
  Noise    noise_;
  ADSR     adsr_;
  SineWave vibrato_;

  StkFloat lastFrequency_;
  StkFloat maxPressure_;
  StkFloat jetReflection_;
  StkFloat endReflection_;
  StkFloat noiseGain_;
  StkFloat vibratoGain_;
  StkFloat outputGain_;
  StkFloat jetRatio_;

};

inline StkFloat Flute :: tick( unsigned int )
{
  StkFloat pressureDiff;
  StkFloat breathPressure;

  // Calculate the breath pressure (envelope + noise + vibrato)
  breathPressure = maxPressure_ * adsr_.tick();
  breathPressure += breathPressure * ( noiseGain_ * noise_.tick() + vibratoGain_ * vibrato_.tick() );

  StkFloat temp = -filter_.tick( boreDelay_.lastOut() );
  temp = dcBlock_.tick( temp ); // Block DC on reflection.

  pressureDiff = breathPressure - (jetReflection_ * temp);
  pressureDiff = jetDelay_.tick( pressureDiff );
  pressureDiff = jetTable_.tick( pressureDiff ) + (endReflection_ * temp);
  lastFrame_[0] = (StkFloat) 0.3 * boreDelay_.tick( pressureDiff );

  lastFrame_[0] *= outputGain_;
  return lastFrame_[0];
}

inline StkFrames& Flute :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Flute::tick(): channel and StkFrames arguments are incompatible!";
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
