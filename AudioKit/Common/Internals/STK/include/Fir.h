#ifndef STK_FIR_H
#define STK_FIR_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class Fir
    \brief STK general finite impulse response filter class.

    This class provides a generic digital filter structure that can be
    used to implement FIR filters.  For filters with feedback terms,
    the Iir class should be used.

    In particular, this class implements the standard difference
    equation:

    y[n] = b[0]*x[n] + ... + b[nb]*x[n-nb]

    The \e gain parameter is applied at the filter input and does not
    affect the coefficient values.  The default gain value is 1.0.
    This structure results in one extra multiply per computed sample,
    but allows easy control of the overall filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Fir : public Filter
{
public:
  //! Default constructor creates a zero-order pass-through "filter".
  Fir( void );

  //! Overloaded constructor which takes filter coefficients.
  /*!
    An StkError can be thrown if the coefficient vector size is
    zero.
  */
  Fir( std::vector<StkFloat> &coefficients );

  //! Class destructor.
  ~Fir( void );

  //! Set filter coefficients.
  /*!
    An StkError can be thrown if the coefficient vector size is
    zero.  The internal state of the filter is not cleared unless the
    \e clearState flag is \c true.
  */
  void setCoefficients( std::vector<StkFloat> &coefficients, bool clearState = false );

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

protected:

};

inline StkFloat Fir :: tick( StkFloat input )
{
  lastFrame_[0] = 0.0;
  inputs_[0] = gain_ * input;

  for ( unsigned int i=(unsigned int)(b_.size())-1; i>0; i-- ) {
    lastFrame_[0] += b_[i] * inputs_[i];
    inputs_[i] = inputs_[i-1];
  }
  lastFrame_[0] += b_[0] * inputs_[0];

  return lastFrame_[0];
}

inline StkFrames& Fir :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Fir::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int i, hop = frames.channels();
  for ( unsigned int j=0; j<frames.frames(); j++, samples += hop ) {
    inputs_[0] = gain_ * *samples;
    *samples = 0.0;

    for ( i=(unsigned int)b_.size()-1; i>0; i-- ) {
      *samples += b_[i] * inputs_[i];
      inputs_[i] = inputs_[i-1];
    }
    *samples += b_[0] * inputs_[0];
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& Fir :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Fir::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int i, iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int j=0; j<iFrames.frames(); j++, iSamples += iHop, oSamples += oHop ) {
    inputs_[0] = gain_ * *iSamples;
    *oSamples = 0.0;

    for ( i=(unsigned int)b_.size()-1; i>0; i-- ) {
      *oSamples += b_[i] * inputs_[i];
      inputs_[i] = inputs_[i-1];
    }
    *oSamples += b_[0] * inputs_[0];
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
