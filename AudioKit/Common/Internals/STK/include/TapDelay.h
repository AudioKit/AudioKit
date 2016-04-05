#ifndef STK_TAPDELAY_H
#define STK_TAPDELAY_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class TapDelay
    \brief STK non-interpolating tapped delay line class.

    This class implements a non-interpolating digital delay-line with
    an arbitrary number of output "taps".  If the maximum length and
    tap delays are not specified during instantiation, a fixed maximum
    length of 4095 and a single tap delay of zero is set.
    
    A non-interpolating delay line is typically used in fixed
    delay-length applications, such as for reverberation.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class TapDelay : public Filter
{
 public:

  //! The default constructor creates a delay-line with maximum length of 4095 samples and a single tap at delay = 0.
  /*!
    An StkError will be thrown if any tap delay parameter is less
    than zero, the maximum delay parameter is less than one, or any
    tap delay parameter is greater than the maxDelay value.
   */
  TapDelay( std::vector<unsigned long> taps = std::vector<unsigned long>( 1, 0 ), unsigned long maxDelay = 4095 );

  //! Class destructor.
  ~TapDelay();

  //! Set the maximum delay-line length.
  /*!
    This method should generally only be used during initial setup
    of the delay line.  If it is used between calls to the tick()
    function, without a call to clear(), a signal discontinuity will
    likely occur.  If the current maximum length is greater than the
    new length, no change will be made.
  */
  void setMaximumDelay( unsigned long delay );

  //! Set the delay-line tap lengths.
  /*!
    The valid range for each tap length is from 0 to the maximum delay-line length.
  */
  void setTapDelays( std::vector<unsigned long> taps );

  //! Return the current delay-line length.
  std::vector<unsigned long> getTapDelays( void ) const { return delays_; };

  //! Return the specified tap value of the last computed frame.
  /*!
    Use the lastFrame() function to get all tap values from the
    last computed frame.  The \c tap argument must be less than the
    number of delayline taps (the first tap is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFloat lastOut( unsigned int tap = 0 ) const;

  //! Input one sample to the delayline and return outputs at all tap positions.
  /*!
    The StkFrames argument reference is returned.  The output
    values are ordered according to the tap positions set using the
    setTapDelays() function (no sorting is performed).  The StkFrames
    argument must contain at least as many channels as the number of
    taps.  However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFloat input, StkFrames& outputs );

  //! Take a channel of the StkFrames object as inputs to the filter and write outputs back to the same object.
  /*!
    The StkFrames argument reference is returned.  The output
    values are ordered according to the tap positions set using the
    setTapDelays() function (no sorting is performed).  The StkFrames
    argument must contain at least as many channels as the number of
    taps.  However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the filter and write outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  The output values
    are ordered according to the tap positions set using the
    setTapDelays() function (no sorting is performed).  The \c
    iChannel argument must be less than the number of channels in
    the \c iFrames argument (the first channel is specified by 0).
    The \c oFrames argument must contain at least as many channels as
    the number of taps.  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0 );

 protected:

  unsigned long inPoint_;
  std::vector<unsigned long> outPoint_;
  std::vector<unsigned long> delays_;

};

inline StkFloat TapDelay :: lastOut( unsigned int tap ) const
{
#if defined(_STK_DEBUG_)
  if ( tap >= lastFrame_.size() ) {
    oStream_ << "TapDelay::lastOut(): tap argument and number of taps are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[tap];
}

inline StkFrames& TapDelay :: tick( StkFloat input, StkFrames& outputs )
{
#if defined(_STK_DEBUG_)
  if ( outputs.channels() < outPoint_.size() ) {
    oStream_ << "TapDelay::tick(): number of taps > channels in StkFrames argument!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  inputs_[inPoint_++] = input * gain_;

  // Check for end condition
  if ( inPoint_ == inputs_.size() )
    inPoint_ = 0;

  // Read out next values
  StkFloat *outs = &outputs[0];
  for ( unsigned int i=0; i<outPoint_.size(); i++ ) {
    *outs++ = inputs_[outPoint_[i]];
    lastFrame_[i] = *outs;
    if ( ++outPoint_[i] == inputs_.size() )
      outPoint_[i] = 0;
  }

  return outputs;
}

inline StkFrames& TapDelay :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "TapDelay::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
  if ( frames.channels() < outPoint_.size() ) {
    oStream_ << "TapDelay::tick(): number of taps > channels in StkFrames argument!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &frames[channel];
  StkFloat *oSamples = &frames[0];
  std::size_t j;
  unsigned int iHop = frames.channels();
  std::size_t oHop = frames.channels() - outPoint_.size();
  for ( unsigned long i=0; i<frames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[inPoint_++] = *iSamples * gain_;
    if ( inPoint_ == inputs_.size() ) inPoint_ = 0;
    for ( j=0; j<outPoint_.size(); j++ ) {
      *oSamples++ = inputs_[outPoint_[j]];
      if ( ++outPoint_[j] == inputs_.size() ) outPoint_[j] = 0;
    }
  }

  oSamples -= frames.channels();
  for ( j=0; j<outPoint_.size(); j++ ) lastFrame_[j] = *oSamples++;
  return frames;
}

inline StkFrames& TapDelay :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() ) {
    oStream_ << "TapDelay::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
  if ( oFrames.channels() < outPoint_.size() ) {
    oStream_ << "TapDelay::tick(): number of taps > channels in output StkFrames argument!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[0];
  std::size_t j;
  unsigned int iHop = iFrames.channels();
  std::size_t oHop = oFrames.channels() - outPoint_.size();
  for ( unsigned long i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[inPoint_++] = *iSamples * gain_;
    if ( inPoint_ == inputs_.size() ) inPoint_ = 0;
    for ( j=0; j<outPoint_.size(); j++ ) {
      *oSamples++ = inputs_[outPoint_[j]];
      if ( ++outPoint_[j] == inputs_.size() ) outPoint_[j] = 0;
    }
  }

  oSamples -= oFrames.channels();
  for ( j=0; j<outPoint_.size(); j++ ) lastFrame_[j] = *oSamples++;
  return iFrames;
}

} // stk namespace

#endif
