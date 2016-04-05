#ifndef STK_TWOPOLE_H
#define STK_TWOPOLE_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class TwoPole
    \brief STK two-pole filter class.

    This class implements a two-pole digital filter.  A method is
    provided for creating a resonance in the frequency response while
    maintaining a nearly constant filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class TwoPole : public Filter
{
 public:

  //! Default constructor creates a second-order pass-through filter.
  TwoPole( void );

  //! Class destructor.
  ~TwoPole();

  //! A function to enable/disable the automatic updating of class data when the STK sample rate changes.
  void ignoreSampleRateChange( bool ignore = true ) { ignoreSampleRateChange_ = ignore; };

  //! Set the b[0] coefficient value.
  void setB0( StkFloat b0 ) { b_[0] = b0; };

  //! Set the a[1] coefficient value.
  void setA1( StkFloat a1 ) { a_[1] = a1; };

  //! Set the a[2] coefficient value.
  void setA2( StkFloat a2 ) { a_[2] = a2; };

  //! Set all filter coefficients.
  void setCoefficients( StkFloat b0, StkFloat a1, StkFloat a2, bool clearState = false );

  //! Sets the filter coefficients for a resonance at \e frequency (in Hz).
  /*!
    This method determines the filter coefficients corresponding to
    two complex-conjugate poles with the given \e frequency (in Hz)
    and \e radius from the z-plane origin.  If \e normalize is true,
    the coefficients are then normalized to produce unity gain at \e
    frequency (the actual maximum filter gain tends to be slightly
    greater than unity when \e radius is not close to one).  The
    resulting filter frequency response has a resonance at the given
    \e frequency.  The closer the poles are to the unit-circle (\e
    radius close to one), the narrower the resulting resonance width.
    An unstable filter will result for \e radius >= 1.0.  The
    \e frequency value should be between zero and half the sample rate.
    For a better resonance filter, use a BiQuad filter. \sa BiQuad
    filter class
  */
  void setResonance(StkFloat frequency, StkFloat radius, bool normalize = false);

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

  virtual void sampleRateChanged( StkFloat newRate, StkFloat oldRate );
};

inline StkFloat TwoPole :: tick( StkFloat input )
{
  inputs_[0] = gain_ * input;
  lastFrame_[0] = b_[0] * inputs_[0] - a_[1] * outputs_[1] - a_[2] * outputs_[2];
  outputs_[2] = outputs_[1];
  outputs_[1] = lastFrame_[0];

  return lastFrame_[0];
}

inline StkFrames& TwoPole :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "TwoPole::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    inputs_[0] = gain_ * *samples;
    *samples = b_[0] * inputs_[0] - a_[1] * outputs_[1] - a_[2] * outputs_[2];
    outputs_[2] = outputs_[1];
    outputs_[1] = *samples;
  }

  lastFrame_[0] = outputs_[1];
  return frames;
}

inline StkFrames& TwoPole :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "TwoPole::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[0] = gain_ * *iSamples;
    *oSamples = b_[0] * inputs_[0] - a_[1] * outputs_[1] - a_[2] * outputs_[2];
    outputs_[2] = outputs_[1];
    outputs_[1] = *oSamples;
  }

  lastFrame_[0] = outputs_[1];
  return iFrames;
}

} // stk namespace

#endif
