#ifndef STK_DELAYL_H
#define STK_DELAYL_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class DelayL
    \brief STK linear interpolating delay line class.

    This class implements a fractional-length digital delay-line using
    first-order linear interpolation.  If the delay and maximum length
    are not specified during instantiation, a fixed maximum length of
    4095 and a delay of zero is set.

    Linear interpolation is an efficient technique for achieving
    fractional delay lengths, though it does introduce high-frequency
    signal attenuation to varying degrees depending on the fractional
    delay setting.  The use of higher order Lagrange interpolators can
    typically improve (minimize) this attenuation characteristic.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class DelayL : public Filter
{
public:

  //! Default constructor creates a delay-line with maximum length of 4095 samples and zero delay.
  /*!
    An StkError will be thrown if the delay parameter is less than
    zero, the maximum delay parameter is less than one, or the delay
    parameter is greater than the maxDelay value.
   */  
  DelayL( StkFloat delay = 0.0, unsigned long maxDelay = 4095 );

  //! Class destructor.
  ~DelayL();

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
  void setDelay( StkFloat delay );

  //! Return the current delay-line length.
  StkFloat getDelay( void ) const { return delay_; };

  //! Return the value at \e tapDelay samples from the delay-line input.
  /*!
    The tap point is determined modulo the delay-line length and is
    relative to the last input value (i.e., a tapDelay of zero returns
    the last input value).
  */
  StkFloat tapOut( unsigned long tapDelay );

  //! Set the \e value at \e tapDelay samples from the delay-line input.
  void tapIn( StkFloat value, unsigned long tapDelay );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Return the value which will be output by the next call to tick().
  /*!
    This method is valid only for delay settings greater than zero!
   */
  StkFloat nextOut( void );

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
  StkFloat delay_;
  StkFloat alpha_;
  StkFloat omAlpha_;
  StkFloat nextOutput_;
  bool doNextOut_;
};

inline StkFloat DelayL :: nextOut( void )
{
  if ( doNextOut_ ) {
    // First 1/2 of interpolation
    nextOutput_ = inputs_[outPoint_] * omAlpha_;
    // Second 1/2 of interpolation
    if (outPoint_+1 < inputs_.size())
      nextOutput_ += inputs_[outPoint_+1] * alpha_;
    else
      nextOutput_ += inputs_[0] * alpha_;
    doNextOut_ = false;
  }

  return nextOutput_;
}

inline void DelayL :: setDelay( StkFloat delay )
{
  if ( delay + 1 > inputs_.size() ) { // The value is too big.
    oStream_ << "DelayL::setDelay: argument (" << delay << ") greater than  maximum!";
    handleError( StkError::WARNING ); return;
  }

  if (delay < 0 ) {
    oStream_ << "DelayL::setDelay: argument (" << delay << ") less than zero!";
    handleError( StkError::WARNING ); return;
  }

  StkFloat outPointer = inPoint_ - delay;  // read chases write
  delay_ = delay;

  while ( outPointer < 0 )
    outPointer += inputs_.size(); // modulo maximum length

  outPoint_ = (long) outPointer;   // integer part

  alpha_ = outPointer - outPoint_; // fractional part
  omAlpha_ = (StkFloat) 1.0 - alpha_;

  if ( outPoint_ == inputs_.size() ) outPoint_ = 0;
  doNextOut_ = true;
}

inline StkFloat DelayL :: tick( StkFloat input )
{
  inputs_[inPoint_++] = input * gain_;

  // Increment input pointer modulo length.
  if ( inPoint_ == inputs_.size() )
    inPoint_ = 0;

  lastFrame_[0] = nextOut();
  doNextOut_ = true;

  // Increment output pointer modulo length.
  if ( ++outPoint_ == inputs_.size() )
    outPoint_ = 0;

  return lastFrame_[0];
}

inline StkFrames& DelayL :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "DelayL::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    inputs_[inPoint_++] = *samples * gain_;
    if ( inPoint_ == inputs_.size() ) inPoint_ = 0;
    *samples = nextOut();
    doNextOut_ = true;
    if ( ++outPoint_ == inputs_.size() ) outPoint_ = 0;
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& DelayL :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "DelayL::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    inputs_[inPoint_++] = *iSamples * gain_;
    if ( inPoint_ == inputs_.size() ) inPoint_ = 0;
    *oSamples = nextOut();
    doNextOut_ = true;
    if ( ++outPoint_ == inputs_.size() ) outPoint_ = 0;
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif
