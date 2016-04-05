#ifndef STK_DELAY_H
#define STK_DELAY_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class Delay
    \brief STK non-interpolating delay line class.

    This class implements a non-interpolating digital delay-line.  If
    the delay and maximum length are not specified during
    instantiation, a fixed maximum length of 4095 and a delay of zero
    is set.
    
    A non-interpolating delay line is typically used in fixed
    delay-length applications, such as for reverberation.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Delay : public Filter
{
public:

  //! The default constructor creates a delay-line with maximum length of 4095 samples and zero delay.
  /*!
    An StkError will be thrown if the delay parameter is less than
    zero, the maximum delay parameter is less than one, or the delay
    parameter is greater than the maxDelay value.
   */
  Delay( unsigned long delay = 0, unsigned long maxDelay = 4095 );

  //! Class destructor.
  ~Delay();

  //! Get the maximum delay-line length.
  unsigned long getMaximumDelay( void ) { return inputs_.size() - 1; };

  //! Set the maximum delay-line length.
  /*!
    This method should generally only be used during initial setup
    of the delay line.  If it is used between calls to the tick()
    function, without a call to clear(), a signal discontinuity will
    likely occur.  If the current maximum length is greater than the
    new length, no memory allocation change is made.
  */
  void setMaximumDelay( unsigned long delay );

  //! Set the delay-line length.
  /*!
    The valid range for \e delay is from 0 to the maximum delay-line length.
  */
  void setDelay( unsigned long delay );

  //! Return the current delay-line length.
  unsigned long getDelay( void ) const { return delay_; };

  //! Return the value at \e tapDelay samples from the delay-line input.
  /*!
    The tap point is determined modulo the delay-line length and is
    relative to the last input value (i.e., a tapDelay of zero returns
    the last input value).
  */
  StkFloat tapOut( unsigned long tapDelay );

  //! Set the \e value at \e tapDelay samples from the delay-line input.
  void tapIn( StkFloat value, unsigned long tapDelay );

  //! Sum the provided \e value into the delay line at \e tapDelay samples from the input.
  /*!
    The new value is returned.  The tap point is determined modulo
    the delay-line length and is relative to the last input value
    (i.e., a tapDelay of zero sums into the last input value).
  */
  StkFloat addTo( StkFloat value, unsigned long tapDelay );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Return the value that will be output by the next call to tick().
  /*!
    This method is valid only for delay settings greater than zero!
   */
  StkFloat nextOut( void ) { return inputs_[outPoint_]; };

  //! Calculate and return the signal energy in the delay-line.
  StkFloat energy( void ) const;

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

  unsigned long inPoint_;
  unsigned long outPoint_;
  unsigned long delay_;
};

inline StkFloat Delay :: tick( StkFloat input )
{
  inputs_[inPoint_++] = input * gain_;

  // Check for end condition
  if ( inPoint_ == inputs_.size() )
    inPoint_ = 0;

  // Read out next value
  lastFrame_[0] = inputs_[outPoint_++];

  if ( outPoint_ == inputs_.size() )
    outPoint_ = 0;

  return lastFrame_[0];
}

inline StkFrames& Delay :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Delay::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    inputs_[inPoint_++] = *samples * gain_;
    if ( inPoint_ == inputs_.size() ) inPoint_ = 0;
    *samples = inputs_[outPoint_++];
    if ( outPoint_ == inputs_.size() ) outPoint_ = 0;
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& Delay :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Delay::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[inPoint_++] = *iSamples * gain_;
    if ( inPoint_ == inputs_.size() ) inPoint_ = 0;
    *oSamples = inputs_[outPoint_++];
    if ( outPoint_ == inputs_.size() ) outPoint_ = 0;
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
