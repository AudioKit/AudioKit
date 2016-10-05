#ifndef STK_CUBIC_H
#define STK_CUBIC_H

#include "Function.h"
#include <cmath>

namespace stk {

/***************************************************/
/*! \class Cubic
    \brief STK cubic non-linearity class.

    This class implements the cubic non-linearity
    that was used in SynthBuilder.

    The formula implemented is:
 
    \code
    output = gain * (a1 * input + a2 * input^2 + a3 * input^3)
    \endcode

    followed by a limiter for values outside +-threshold.

    Ported to STK by Nick Porcaro, 2007. Updated for inclusion
    in STK distribution by Gary Scavone, 2011.
*/
/***************************************************/

class Cubic : public Function
{
public:
  //! Default constructor.
  Cubic( void ) : a1_(0.5), a2_(0.5), a3_(0.5), gain_(1.0), threshold_(1.0) {};

  //! Set the a1 coefficient value.
  void setA1( StkFloat a1 ) { a1_ = a1; };

  //! Set the a2 coefficient value.
  void setA2( StkFloat a2 )  { a2_ = a2; };

  //! Set the a3 coefficient value.
  void setA3( StkFloat a3 )  { a3_ = a3; };

  //! Set the gain value.
  void setGain( StkFloat gain ) { gain_ = gain; };

  //! Set the threshold value.
  void setThreshold( StkFloat threshold ) { threshold_ = threshold; };

  //! Input one sample to the function and return one output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the function and replace with corresponding outputs.
  /*!
    The StkFrames argument reference is returned.  The \c channel
    argument must be less than the number of channels in the
    StkFrames argument (the first channel is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the function and write outputs to the \c oFrames object.
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

  StkFloat a1_;
  StkFloat a2_;
  StkFloat a3_;
  StkFloat gain_; 
  StkFloat threshold_;
};

inline StkFloat Cubic :: tick( StkFloat input )
{
  StkFloat inSquared = input * input;
  StkFloat inCubed = inSquared * input;

  lastFrame_[0] = gain_ * (a1_ * input + a2_ * inSquared + a3_ * inCubed);

  // Apply threshold if we are out of range.
  if ( fabs( lastFrame_[0] ) > threshold_ ) {
    lastFrame_[0] = ( lastFrame_[0] < 0 ? -threshold_ : threshold_ );
  }

  return lastFrame_[0];
}

inline StkFrames& Cubic :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Cubic::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = tick( *samples );

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& Cubic :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Cubic::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop )
    *oSamples = tick( *iSamples );

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
