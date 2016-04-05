#ifndef STK_TWANG_H
#define STK_TWANG_H

#include "Stk.h"
#include "DelayA.h"
#include "DelayL.h"
#include "Fir.h"

namespace stk {

/***************************************************/
/*! \class Twang
    \brief STK enhanced plucked string class.

    This class implements an enhanced plucked-string
    physical model, a la Jaffe-Smith, Smith,
    Karjalainen and others.  It includes a comb
    filter to simulate pluck position.  The tick()
    function takes an input sample, which is added
    to the delayline input.  This can be used to
    implement commuted synthesis (if the input
    samples are derived from the impulse response of
    a body filter) and/or feedback (as in an electric
    guitar model).

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Twang : public Stk
{
 public:
  //! Class constructor, taking the lowest desired playing frequency.
  Twang( StkFloat lowestFrequency = 50.0 );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set the delayline parameters to allow frequencies as low as specified.
  void setLowestFrequency( StkFloat frequency );

  //! Set the delayline parameters for a particular frequency.
  void setFrequency( StkFloat frequency );

  //! Set the pluck or "excitation" position along the string (0.0 - 1.0).
  void setPluckPosition( StkFloat position );

  //! Set the nominal loop gain.
  /*!
    The actual loop gain is based on the value set with this
    function, but scaled slightly according to the frequency.  Higher
    frequency settings have greater loop gains because of
    high-frequency loop-filter roll-off.
  */
  void setLoopGain( StkFloat loopGain );

  //! Set the loop filter coefficients.
  /*!
    The loop filter can be any arbitrary FIR filter.  By default,
    the coefficients are set for a first-order lowpass filter with
    coefficients b = [0.5 0.5].
  */
  void setLoopFilter( std::vector<StkFloat> coefficients );

  //! Return an StkFrames reference to the last output sample frame.
  //const StkFrames& lastFrame( void ) const { return lastFrame_; };

  //! Return the last computed output value.
  // StkFloat lastOut( void ) { return lastFrame_[0]; };
  StkFloat lastOut( void ) { return lastOutput_; };

  //! Compute and return one output sample.
  StkFloat tick( StkFloat input );

  //! Take a channel of the \c iFrames object as inputs to the class and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  Each channel
    argument must be less than the number of channels in the
    corresponding StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
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

  DelayA   delayLine_;
  DelayL   combDelay_;
  Fir      loopFilter_;

  StkFloat lastOutput_;
  StkFloat frequency_;
  StkFloat loopGain_;
  StkFloat pluckPosition_;
};

inline StkFloat Twang :: tick( StkFloat input )
{
  lastOutput_ = delayLine_.tick( input + loopFilter_.tick( delayLine_.lastOut() ) );
  lastOutput_ -= combDelay_.tick( lastOutput_ ); // comb filtering on output
  lastOutput_ *= 0.5;

  return lastOutput_;
}

inline StkFrames& Twang :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Twang::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = tick( *samples );

  return frames;
}

inline StkFrames& Twang :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Twang::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop )
    *oSamples = tick( *iSamples );

  return iFrames;
}

} // stk namespace

#endif

