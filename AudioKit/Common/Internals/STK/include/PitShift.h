#ifndef STK_PITSHIFT_H
#define STK_PITSHIFT_H

#include "Effect.h"
#include "DelayL.h"

namespace stk {

/***************************************************/
/*! \class PitShift
    \brief STK simple pitch shifter effect class.

    This class implements a simple pitch shifter
    using delay lines.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

const int maxDelay = 5024;

class PitShift : public Effect
{
 public:
  //! Class constructor.
  PitShift( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set the pitch shift factor (1.0 produces no shift).
  void setShift( StkFloat shift );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Input one sample to the effect and return one output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the effect and replace with corresponding outputs.
  /*!
    The StkFrames argument reference is returned.  The \c channel
    argument must be less than the number of channels in the
    StkFrames argument (the first channel is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the effect and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  Each channel
    argument must be less than the number of channels in the
    corresponding StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0, unsigned int oChannel = 0 );

 protected:

  DelayL delayLine_[2];
  StkFloat delay_[2];
  StkFloat env_[2];
  StkFloat rate_;
  unsigned long delayLength_;
  unsigned long halfLength_;

};

inline StkFloat PitShift :: tick( StkFloat input )
{
  // Calculate the two delay length values, keeping them within the
  // range 12 to maxDelay-12.
  delay_[0] += rate_;
  while ( delay_[0] > maxDelay-12 ) delay_[0] -= delayLength_;
  while ( delay_[0] < 12 ) delay_[0] += delayLength_;

  delay_[1] = delay_[0] + halfLength_;
  while ( delay_[1] > maxDelay-12 ) delay_[1] -= delayLength_;
  while ( delay_[1] < 12 ) delay_[1] += delayLength_;

  // Set the new delay line lengths.
  delayLine_[0].setDelay( delay_[0] );
  delayLine_[1].setDelay( delay_[1] );

  // Calculate a triangular envelope.
  env_[1] = fabs( ( delay_[0] - halfLength_ + 12 ) * ( 1.0 / (halfLength_ + 12 ) ) );
  env_[0] = 1.0 - env_[1];

  // Delay input and apply envelope.
  lastFrame_[0] =  env_[0] * delayLine_[0].tick( input );
  lastFrame_[0] += env_[1] * delayLine_[1].tick( input );

  // Compute effect mix and output.
  lastFrame_[0] *= effectMix_;
  lastFrame_[0] += ( 1.0 - effectMix_ ) * input;

  return lastFrame_[0];
}

} // stk namespace

#endif

