#ifndef STK_BOWED_H
#define STK_BOWED_H

#include "Instrmnt.h"
#include "DelayL.h"
#include "BowTable.h"
#include "OnePole.h"
#include "BiQuad.h"
#include "SineWave.h"
#include "ADSR.h"

namespace stk {

/***************************************************/
/*! \class Bowed
    \brief STK bowed string instrument class.

    This class implements a bowed string model, a
    la Smith (1986), after McIntyre, Schumacher,
    Woodhouse (1983).

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.

    Control Change Numbers: 
       - Bow Pressure = 2
       - Bow Position = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Bow Velocity = 100
       - Frequency = 101
       - Volume = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
    Contributions by Esteban Maestre, 2011.
*/
/***************************************************/

class Bowed : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  Bowed( StkFloat lowestFrequency = 8.0 );

  //! Class destructor.
  ~Bowed( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set vibrato gain.
  void setVibrato( StkFloat gain ) { vibratoGain_ = gain; };

  //! Apply breath pressure to instrument with given amplitude and rate of increase.
  void startBowing( StkFloat amplitude, StkFloat rate );

  //! Decrease breath pressure with given rate of decrease.
  void stopBowing( StkFloat rate );

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

  DelayL   neckDelay_;
  DelayL   bridgeDelay_;
  BowTable bowTable_;
  OnePole  stringFilter_;
  BiQuad   bodyFilters_[6];
  SineWave vibrato_;
  ADSR     adsr_;

  bool     bowDown_;
  StkFloat maxVelocity_;
  StkFloat baseDelay_;
  StkFloat vibratoGain_;
  StkFloat betaRatio_;

};

inline StkFloat Bowed :: tick( unsigned int )
{
  StkFloat bowVelocity = maxVelocity_ * adsr_.tick();
  StkFloat bridgeReflection = -stringFilter_.tick( bridgeDelay_.lastOut() );
  StkFloat nutReflection = -neckDelay_.lastOut();
  StkFloat stringVelocity = bridgeReflection + nutReflection;
  StkFloat deltaV = bowVelocity - stringVelocity;             // Differential velocity

  StkFloat newVelocity = 0.0;
  if ( bowDown_ )
    newVelocity = deltaV * bowTable_.tick( deltaV );     // Non-Linear bow function
  neckDelay_.tick( bridgeReflection + newVelocity);      // Do string propagations
  bridgeDelay_.tick(nutReflection + newVelocity);
    
  if ( vibratoGain_ > 0.0 )  {
    neckDelay_.setDelay( (baseDelay_ * (1.0 - betaRatio_) ) + 
                         (baseDelay_ * vibratoGain_ * vibrato_.tick()) );
  }

  lastFrame_[0] = 0.1248 * bodyFilters_[5].tick( bodyFilters_[4].tick( bodyFilters_[3].tick( bodyFilters_[2].tick( bodyFilters_[1].tick( bodyFilters_[0].tick( bridgeDelay_.lastOut() ) ) ) ) ) );

  return lastFrame_[0];
}

inline StkFrames& Bowed :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Bowed::tick(): channel and StkFrames arguments are incompatible!";
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
