#ifndef STK_ONEZERO_H
#define STK_ONEZERO_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class OneZero
  \brief STK one-zero filter class.

  This class implements a one-zero digital filter.  A method is
  provided for setting the zero position along the real axis of the
  z-plane while maintaining a constant filter gain.

  by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class OneZero : public Filter
{
 public:

  //! The default constructor creates a low-pass filter (zero at z = -1.0).
  OneZero( StkFloat theZero = -1.0 );

  //! Class destructor.
  ~OneZero();

  //! Set the b[0] coefficient value.
  void setB0( StkFloat b0 ) { b_[0] = b0; };

  //! Set the b[1] coefficient value.
  void setB1( StkFloat b1 ) { b_[1] = b1; };

  //! Set all filter coefficients.
  void setCoefficients( StkFloat b0, StkFloat b1, bool clearState = false );

  //! Set the zero position in the z-plane.
  /*!
    This method sets the zero position along the real-axis of the
    z-plane and normalizes the coefficients for a maximum gain of one.
    A positive zero value produces a high-pass filter, while a
    negative zero value produces a low-pass filter.  This method does
    not affect the filter \e gain value.
  */
  void setZero( StkFloat theZero );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Input one sample to the filter and return one output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the filter and replace with corresponding outputs.
  /*!
    The StkFrames argument reference is returned.  The \c channel
    argument must be less than the number of channels in the
    StkFrames argument (the first channel is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the filter and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  Each channel
    argument must be less than the number of channels in the
    corresponding StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0, unsigned int oChannel = 0 );

};

inline StkFloat OneZero :: tick( StkFloat input )
{
  inputs_[0] = gain_ * input;
  lastFrame_[0] = b_[1] * inputs_[1] + b_[0] * inputs_[0];
  inputs_[1] = inputs_[0];

  return lastFrame_[0];
}

inline StkFrames& OneZero :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "OneZero::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    inputs_[0] = gain_ * *samples;
    *samples = b_[1] * inputs_[1] + b_[0] * inputs_[0];
    inputs_[1] = inputs_[0];
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& OneZero :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "OneZero::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[0] = gain_ * *iSamples;
    *oSamples = b_[1] * inputs_[1] + b_[0] * inputs_[0];
    inputs_[1] = inputs_[0];
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif

