#ifndef STK_TWOZERO_H
#define STK_TWOZERO_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class TwoZero
    \brief STK two-zero filter class.

    This class implements a two-zero digital filter.  A method is
    provided for creating a "notch" in the frequency response while
    maintaining a constant filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class TwoZero : public Filter
{
 public:
  //! Default constructor creates a second-order pass-through filter.
  TwoZero();

  //! Class destructor.
  ~TwoZero();

  //! A function to enable/disable the automatic updating of class data when the STK sample rate changes.
  void ignoreSampleRateChange( bool ignore = true ) { ignoreSampleRateChange_ = ignore; };

  //! Set the b[0] coefficient value.
  void setB0( StkFloat b0 ) { b_[0] = b0; };

  //! Set the b[1] coefficient value.
  void setB1( StkFloat b1 ) { b_[1] = b1; };

  //! Set the b[2] coefficient value.
  void setB2( StkFloat b2 ) { b_[2] = b2; };

  //! Set all filter coefficients.
  void setCoefficients( StkFloat b0, StkFloat b1, StkFloat b2, bool clearState = false );

  //! Sets the filter coefficients for a "notch" at \e frequency (in Hz).
  /*!
    This method determines the filter coefficients corresponding to
    two complex-conjugate zeros with the given \e frequency (in Hz)
    and \e radius from the z-plane origin.  The coefficients are then
    normalized to produce a maximum filter gain of one (independent of
    the filter \e gain parameter).  The resulting filter frequency
    response has a "notch" or anti-resonance at the given \e
    frequency.  The closer the zeros are to the unit-circle (\e radius
    close to or equal to one), the narrower the resulting notch width.
    The \e frequency value should be between zero and half the sample
    rate.  The \e radius value should be positive.
  */
  void setNotch( StkFloat frequency, StkFloat radius );

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

  void sampleRateChanged( StkFloat newRate, StkFloat oldRate );
};

inline StkFloat TwoZero :: tick( StkFloat input )
{
  inputs_[0] = gain_ * input;
  lastFrame_[0] = b_[2] * inputs_[2] + b_[1] * inputs_[1] + b_[0] * inputs_[0];
  inputs_[2] = inputs_[1];
  inputs_[1] = inputs_[0];

  return lastFrame_[0];
}

inline StkFrames& TwoZero :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "TwoZero::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    inputs_[0] = gain_ * *samples;
    *samples = b_[2] * inputs_[2] + b_[1] * inputs_[1] + b_[0] * inputs_[0];
    inputs_[2] = inputs_[1];
    inputs_[1] = inputs_[0];
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& TwoZero :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "TwoZero::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[0] = gain_ * *iSamples;
    *oSamples = b_[2] * inputs_[2] + b_[1] * inputs_[1] + b_[0] * inputs_[0];
    inputs_[2] = inputs_[1];
    inputs_[1] = inputs_[0];
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
