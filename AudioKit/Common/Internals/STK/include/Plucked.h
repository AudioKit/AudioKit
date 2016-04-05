#ifndef STK_PLUCKED_H
#define STK_PLUCKED_H

#include "Instrmnt.h"
#include "DelayA.h"
#include "OneZero.h"
#include "OnePole.h"
#include "Noise.h"

namespace stk {

/***************************************************/
/*! \class Plucked
    \brief STK basic plucked string class.

    This class implements a simple plucked string
    physical model based on the Karplus-Strong
    algorithm.

    For a more advanced plucked string implementation,
    see the stk::Twang class.

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.
    There exist at least two patents, assigned to
    Stanford, bearing the names of Karplus and/or
    Strong.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Plucked : public Instrmnt
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  Plucked( StkFloat lowestFrequency = 10.0 );

  //! Class destructor.
  ~Plucked( void );

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

  DelayA   delayLine_;
  OneZero  loopFilter_;
  OnePole  pickFilter_;
  Noise    noise_;

  StkFloat loopGain_;
};

inline StkFloat Plucked :: tick( unsigned int )
{
  // Here's the whole inner loop of the instrument!!
  return lastFrame_[0] = 3.0 * delayLine_.tick( loopFilter_.tick( delayLine_.lastOut() * loopGain_ ) ); 
}

inline StkFrames& Plucked :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Plucked::tick(): channel and StkFrames arguments are incompatible!";
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

