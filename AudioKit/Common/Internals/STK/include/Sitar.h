#ifndef STK_SITAR_H
#define STK_SITAR_H

#include "Instrmnt.h"
#include "DelayA.h"
#include "OneZero.h"
#include "Noise.h"
#include "ADSR.h"
#include <cmath>

namespace stk {

/***************************************************/
/*! \class Sitar
    \brief STK sitar string model class.

    This class implements a sitar plucked string
    physical model based on the Karplus-Strong
    algorithm.

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.
    There exist at least two patents, assigned to
    Stanford, bearing the names of Karplus and/or
    Strong.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Sitar : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  Sitar( StkFloat lowestFrequency = 8.0 );

  //! Class destructor.
  ~Sitar( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set instrument parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Pluck the string with the given amplitude using the current frequency.
  void pluck( StkFloat amplitude );

  //! Start a note with the given frequency and amplitude.
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

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
  OneZero loopFilter_;
  Noise   noise_;
  ADSR    envelope_;

  StkFloat loopGain_;
  StkFloat amGain_;
  StkFloat delay_;
  StkFloat targetDelay_;

};

inline StkFloat Sitar :: tick( unsigned int )
{
  if ( fabs(targetDelay_ - delay_) > 0.001 ) {
    if ( targetDelay_ < delay_ )
      delay_ *= 0.99999;
    else
      delay_ *= 1.00001;
    delayLine_.setDelay( delay_ );
  }

  lastFrame_[0] = delayLine_.tick( loopFilter_.tick( delayLine_.lastOut() * loopGain_ ) + 
                                (amGain_ * envelope_.tick() * noise_.tick()));
  
  return lastFrame_[0];
}

inline StkFrames& Sitar :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Sitar::tick(): channel and StkFrames arguments are incompatible!";
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

