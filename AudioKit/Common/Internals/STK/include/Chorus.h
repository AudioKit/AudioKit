#ifndef STK_CHORUS_H
#define STK_CHORUS_H

#include "Effect.h"
#include "DelayL.h"
#include "SineWave.h"

namespace stk {

/***************************************************/
/*! \class Chorus
    \brief STK chorus effect class.

    This class implements a chorus effect.  It takes a monophonic
    input signal and produces a stereo output signal.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Chorus : public Effect
{
 public:
  //! Class constructor, taking the median desired delay length.
  /*!
    An StkError can be thrown if the rawwave path is incorrect.
  */
  Chorus( StkFloat baseDelay = 6000 );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set modulation depth in range 0.0 - 1.0.
  void setModDepth( StkFloat depth );

  //! Set modulation frequency.
  void setModFrequency( StkFloat frequency );

  //! Return the specified channel value of the last computed stereo frame.
  /*!
    Use the lastFrame() function to get both values of the last
    computed stereo frame.  The \c channel argument must be 0 or 1
    (the first channel is specified by 0).  However, range checking is
    only performed if _STK_DEBUG_ is defined during compilation, in
    which case an out-of-range value will trigger an StkError
    exception.
  */
  StkFloat lastOut( unsigned int channel = 0 );

  //! Input one sample to the effect and return the specified \c channel value of the computed stereo frame.
  /*!
    Use the lastFrame() function to get both values of the computed
    stereo output frame. The \c channel argument must be 0 or 1 (the
    first channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFloat tick( StkFloat input, unsigned int channel = 0 );

  //! Take a channel of the StkFrames object as inputs to the effect and replace with stereo outputs.
  /*!
    The StkFrames argument reference is returned.  The stereo
    outputs are written to the StkFrames argument starting at the
    specified \c channel.  Therefore, the \c channel argument must be
    less than ( channels() - 1 ) of the StkFrames argument (the first
    channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take a channel of the \c iFrames object as inputs to the effect and write stereo outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  The \c iChannel
    argument must be less than the number of channels in the \c
    iFrames argument (the first channel is specified by 0).  The \c
    oChannel argument must be less than ( channels() - 1 ) of the \c
    oFrames argument.  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0, unsigned int oChannel = 0 );

 protected:

  DelayL delayLine_[2];
  SineWave mods_[2];
  StkFloat baseLength_;
  StkFloat modDepth_;

};

inline StkFloat Chorus :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "Chorus::lastOut(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

inline StkFloat Chorus :: tick( StkFloat input, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "Chorus::tick(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  delayLine_[0].setDelay( baseLength_ * 0.707 * ( 1.0 + modDepth_ * mods_[0].tick() ) );
  delayLine_[1].setDelay( baseLength_  * 0.5 *  ( 1.0 - modDepth_ * mods_[1].tick() ) );
  lastFrame_[0] = effectMix_ * ( delayLine_[0].tick( input ) - input ) + input;
  lastFrame_[1] = effectMix_ * ( delayLine_[1].tick( input ) - input ) + input;
  return lastFrame_[channel];
}

inline StkFrames& Chorus :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() - 1 ) {
    oStream_ << "Chorus::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels() - 1;
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    delayLine_[0].setDelay( baseLength_ * 0.707 * ( 1.0 + modDepth_ * mods_[0].tick() ) );
    delayLine_[1].setDelay( baseLength_  * 0.5 *  ( 1.0 - modDepth_ * mods_[1].tick() ) );
    *samples = effectMix_ * ( delayLine_[0].tick( *samples ) - *samples ) + *samples;
    samples++;
    *samples = effectMix_ * ( delayLine_[1].tick( *samples ) - *samples ) + *samples;
  }

  lastFrame_[0] = *(samples-hop);
  lastFrame_[1] = *(samples-hop+1);
  return frames;
}

inline StkFrames& Chorus :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() - 1 ) {
    oStream_ << "Chorus::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    delayLine_[0].setDelay( baseLength_ * 0.707 * ( 1.0 + modDepth_ * mods_[0].tick() ) );
    delayLine_[1].setDelay( baseLength_  * 0.5 *  ( 1.0 - modDepth_ * mods_[1].tick() ) );
    *oSamples = effectMix_ * ( delayLine_[0].tick( *iSamples ) - *iSamples ) + *iSamples;
    *(oSamples+1) = effectMix_ * ( delayLine_[1].tick( *iSamples ) - *iSamples ) + *iSamples;
  }

  lastFrame_[0] = *(oSamples-oHop);
  lastFrame_[1] = *(oSamples-oHop+1);
  return iFrames;
}

} // stk namespace

#endif

