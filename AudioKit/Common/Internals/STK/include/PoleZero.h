#ifndef STK_POLEZERO_H
#define STK_POLEZERO_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class PoleZero
    \brief STK one-pole, one-zero filter class.

    This class implements a one-pole, one-zero digital filter.  A
    method is provided for creating an allpass filter with a given
    coefficient.  Another method is provided to create a DC blocking
    filter.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class PoleZero : public Filter
{
 public:

  //! Default constructor creates a first-order pass-through filter.
  PoleZero();

  //! Class destructor.
  ~PoleZero();

  //! Set the b[0] coefficient value.
  void setB0( StkFloat b0 ) { b_[0] = b0; };

  //! Set the b[1] coefficient value.
  void setB1( StkFloat b1 ) { b_[1] = b1; };

  //! Set the a[1] coefficient value.
  void setA1( StkFloat a1 ) { a_[1] = a1; };

  //! Set all filter coefficients.
  void setCoefficients( StkFloat b0, StkFloat b1, StkFloat a1, bool clearState = false );

  //! Set the filter for allpass behavior using \e coefficient.
  /*!
    This method uses \e coefficient to create an allpass filter,
    which has unity gain at all frequencies.  Note that the
    \e coefficient magnitude must be less than one to maintain
    filter stability.
  */
  void setAllpass( StkFloat coefficient );

  //! Create a DC blocking filter with the given pole position in the z-plane.
  /*!
    This method sets the given pole position, together with a zero
    at z=1, to create a DC blocking filter.  The argument magnitude
    should be close to (but less than) one to minimize low-frequency
    attenuation.
  */
  void setBlockZero( StkFloat thePole = 0.99 );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Input one sample to the filter and return one output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the filter and replace with corresponding outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

};

inline StkFloat PoleZero :: tick( StkFloat input )
{
  inputs_[0] = gain_ * input;
  lastFrame_[0] = b_[0] * inputs_[0] + b_[1] * inputs_[1] - a_[1] * outputs_[1];
  inputs_[1] = inputs_[0];
  outputs_[1] = lastFrame_[0];

  return lastFrame_[0];
}

inline StkFrames& PoleZero :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "PoleZero::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    inputs_[0] = gain_ * *samples;
    *samples = b_[0] * inputs_[0] + b_[1] * inputs_[1] - a_[1] * outputs_[1];
    inputs_[1] = inputs_[0];
    outputs_[1] = *samples;
  }

  lastFrame_[0] = outputs_[1];
  return frames;
}

} // stk namespace

#endif
