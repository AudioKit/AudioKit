#ifndef STK_ECHO_H
#define STK_ECHO_H

#include "Effect.h" 
#include "Delay.h" 

namespace stk {

/***************************************************/
/*! \class Echo
    \brief STK echo effect class.

    This class implements an echo effect.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Echo : public Effect
{
 public:
  //! Class constructor, taking the longest desired delay length (one second default value).
  /*!
    The default delay value is set to 1/2 the maximum delay length.
  */
  Echo( unsigned long maximumDelay = (unsigned long) Stk::sampleRate() );

  //! Reset and clear all internal state.
  void clear();

  //! Set the maximum delay line length in samples.
  void setMaximumDelay( unsigned long delay );

  //! Set the delay line length in samples.
  void setDelay( unsigned long delay );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Input one sample to the effect and return one output.
  StkFloat tick( StkFloat input );

  //! Take a channel of the StkFrames object as inputs to the effect and replace with corresponding outputs.
  /*!
    The StkFrames argument reference is returned.  The \c channel
    argument must be less than the number of channels in the
    StkFrames argument (the first channel is specified by 0).
    However, range checking is only performed if _STK_DEBUG_ is
    defined during compilation, in which case an out-of-range value
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

  Delay delayLine_;
  unsigned long length_;

};

inline StkFloat Echo :: tick( StkFloat input )
{
  lastFrame_[0] = effectMix_ * ( delayLine_.tick( input ) - input ) + input;
  return lastFrame_[0];
}

inline StkFrames& Echo :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Echo::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = effectMix_ * ( delayLine_.tick( *samples ) - *samples ) + *samples;
  }

  lastFrame_[0] = *(samples-hop);
  return frames;
}

inline StkFrames& Echo :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "Echo::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    *oSamples = effectMix_ * ( delayLine_.tick( *iSamples ) - *iSamples ) + *iSamples;
  }

  lastFrame_[0] = *(oSamples-oHop);
  return iFrames;
}

} // stk namespace

#endif

