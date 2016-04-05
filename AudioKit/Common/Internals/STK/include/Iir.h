#ifndef STK_IIR_H
#define STK_IIR_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class Iir
    \brief STK general infinite impulse response filter class.

    This class provides a generic digital filter structure that can be
    used to implement IIR filters.  For filters containing only
    feedforward terms, the Fir class is slightly more efficient.

    In particular, this class implements the standard difference
    equation:

    a[0]*y[n] = b[0]*x[n] + ... + b[nb]*x[n-nb] -
                a[1]*y[n-1] - ... - a[na]*y[n-na]

    If a[0] is not equal to 1, the filter coeffcients are normalized
    by a[0].

    The \e gain parameter is applied at the filter input and does not
    affect the coefficient values.  The default gain value is 1.0.
    This structure results in one extra multiply per computed sample,
    but allows easy control of the overall filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Iir : public Filter
{
public:
  //! Default constructor creates a zero-order pass-through "filter".
  Iir( void );

  //! Overloaded constructor which takes filter coefficients.
  /*!
    An StkError can be thrown if either of the coefficient vector
    sizes is zero, or if the a[0] coefficient is equal to zero.
  */
  Iir( std::vector<StkFloat> &bCoefficients, std::vector<StkFloat> &aCoefficients );

  //! Class destructor.
  ~Iir( void );

  //! Set filter coefficients.
  /*!
    An StkError can be thrown if either of the coefficient vector
    sizes is zero, or if the a[0] coefficient is equal to zero.  If
    a[0] is not equal to 1, the filter coeffcients are normalized by
    a[0].  The internal state of the filter is not cleared unless the
    \e clearState flag is \c true.
  */
  void setCoefficients( std::vector<StkFloat> &bCoefficients, std::vector<StkFloat> &aCoefficients, bool clearState = false );

  //! Set numerator coefficients.
  /*!
    An StkError can be thrown if coefficient vector is empty.  Any
    previously set denominator coefficients are left unaffected.  Note
    that the default constructor sets the single denominator
    coefficient a[0] to 1.0.  The internal state of the filter is not
    cleared unless the \e clearState flag is \c true.
  */
  void setNumerator( std::vector<StkFloat> &bCoefficients, bool clearState = false );

  //! Set denominator coefficients.
  /*!
    An StkError can be thrown if the coefficient vector is empty or
    if the a[0] coefficient is equal to zero.  Previously set
    numerator coefficients are unaffected unless a[0] is not equal to
    1, in which case all coeffcients are normalized by a[0].  Note
    that the default constructor sets the single numerator coefficient
    b[0] to 1.0.  The internal state of the filter is not cleared
    unless the \e clearState flag is \c true.
  */
  void setDenominator( std::vector<StkFloat> &aCoefficients, bool clearState = false );

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

inline StkFloat Iir :: tick( StkFloat input )
{
  size_t i;

  outputs_[0] = 0.0;
  inputs_[0] = gain_ * input;
  for ( i=b_.size()-1; i>0; i-- ) {
    outputs_[0] += b_[i] * inputs_[i];
    inputs_[i] = inputs_[i-1];
  }
  outputs_[0] += b_[0] * inputs_[0];

  for ( i=a_.size()-1; i>0; i-- ) {
    outputs_[0] += -a_[i] * outputs_[i];
    outputs_[i] = outputs_[i-1];
  }

  lastFrame_[0] = outputs_[0];
  return lastFrame_[0];
}

inline StkFrames& Iir :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Iir::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  size_t i;
  unsigned int hop = frames.channels();
  for ( unsigned int j=0; j<frames.frames(); j++, samples += hop ) {
    outputs_[0] = 0.0;
    inputs_[0] = gain_ * *samples;
    for ( i=b_.size()-1; i>0; i-- ) {
      outputs_[0] += b_[i] * inputs_[i];
      inputs_[i] = inputs_[i-1];
    }
    outputs_[0] += b_[0] * inputs_[0];

    for ( i=a_.size()-1; i>0; i-- ) {
      outputs_[0] += -a_[i] * outputs_[i];
      outputs_[i] = outputs_[i-1];
    }

    *samples = outputs_[0];
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& Iir :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Iir::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  size_t i;
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int j=0; j<iFrames.frames(); j++, iSamples += iHop, oSamples += oHop ) {
    outputs_[0] = 0.0;
    inputs_[0] = gain_ * *iSamples;
    for ( i=b_.size()-1; i>0; i-- ) {
      outputs_[0] += b_[i] * inputs_[i];
      inputs_[i] = inputs_[i-1];
    }
    outputs_[0] += b_[0] * inputs_[0];

    for ( i=a_.size()-1; i>0; i-- ) {
      outputs_[0] += -a_[i] * outputs_[i];
      outputs_[i] = outputs_[i-1];
    }

    *oSamples = outputs_[0];
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
