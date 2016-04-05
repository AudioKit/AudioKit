#ifndef STK_FREEVERB_H
#define STK_FREEVERB_H

#include "Effect.h"
#include "Delay.h"
#include "OnePole.h"

namespace stk {

/***********************************************************************/
/*! \class FreeVerb
    \brief Jezar at Dreampoint's FreeVerb, implemented in STK.

    Freeverb is a free and open-source Schroeder reverberator
    originally implemented in C++. The parameters of the reverberation
    model are exceptionally well tuned. FreeVerb uses 8
    lowpass-feedback-comb-filters in parallel, followed by 4 Schroeder
    allpass filters in series.  The input signal can be either mono or
    stereo, and the output signal is stereo.  The delay lengths are
    optimized for a sample rate of 44100 Hz.

    Ported to STK by Gregory Burlet, 2012.
*/
/***********************************************************************/

class FreeVerb : public Effect
{   
 public:
  //! FreeVerb Constructor
  /*!
    Initializes the effect with default parameters. Note that these defaults
    are slightly different than those in the original implementation of
    FreeVerb [Effect Mix: 0.75; Room Size: 0.75; Damping: 0.25; Width: 1.0;
    Mode: freeze mode off].
  */
  FreeVerb();

  //! Destructor
  ~FreeVerb();

  //! Set the effect mix [0 = mostly dry, 1 = mostly wet].
  void setEffectMix( StkFloat mix );

  //! Set the room size (comb filter feedback gain) parameter [0,1].
  void setRoomSize( StkFloat value );

  //! Get the room size (comb filter feedback gain) parameter.
  StkFloat getRoomSize( void );

  //! Set the damping parameter [0=low damping, 1=higher damping].
  void setDamping( StkFloat value );

  //! Get the damping parameter.
  StkFloat getDamping( void );

  //! Set the width (left-right mixing) parameter [0,1].
  void setWidth( StkFloat value );

  //! Get the width (left-right mixing) parameter.
  StkFloat getWidth( void );

  //! Set the mode [frozen = 1, unfrozen = 0].
  void setMode( bool isFrozen );

  //! Get the current freeze mode [frozen = 1, unfrozen = 0].
  StkFloat getMode( void );

  //! Clears delay lines, etc.
  void clear( void );

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

  //! Input one or two samples to the effect and return the specified \c channel value of the computed stereo frame.
  /*!
    Use the lastFrame() function to get both values of the computed
    stereo output frame. The \c channel argument must be 0 or 1 (the
    first channel is specified by 0).  However, range checking is only
    performed if _STK_DEBUG_ is defined during compilation, in which
    case an out-of-range value will trigger an StkError exception.
  */
  StkFloat tick( StkFloat inputL, StkFloat inputR = 0.0, unsigned int channel = 0 );

  //! Take two channels of the StkFrames object as inputs to the effect and replace with stereo outputs.
  /*!
    The StkFrames argument reference is returned.  The stereo
    inputs are taken from (and written back to) the StkFrames argument
    starting at the specified \c channel.  Therefore, the \c channel
    argument must be less than ( channels() - 1 ) of the StkFrames
    argument (the first channel is specified by 0).  However, range
    checking is only performed if _STK_DEBUG_ is defined during
    compilation, in which case an out-of-range value will trigger an
    StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  //! Take one or two channels of the \c iFrames object as inputs to the effect and write stereo outputs to the \c oFrames object.
  /*!
    The \c iFrames object reference is returned.  The \c iChannel
    argument must be less than the number of channels in the \c
    iFrames argument (the first channel is specified by 0).  If more
    than one channel of data exists in \c iFrames starting from \c
    iChannel, stereo data is input to the effect.  The \c oChannel
    argument must be less than ( channels() - 1 ) of the \c oFrames
    argument.  However, range checking is only performed if
    _STK_DEBUG_ is defined during compilation, in which case an
    out-of-range value will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel = 0, unsigned int oChannel = 0 );

 protected:
  //! Update interdependent parameters.
  void update( void );

  // Clamp very small floats to zero, version from
  // http://music.columbia.edu/pipermail/linux-audio-user/2004-July/013489.html .
  // However, this is for 32-bit floats only.
  //static inline StkFloat undenormalize( volatile StkFloat s ) { 
  //  s += 9.8607615E-32f; 
  //  return s - 9.8607615E-32f; 
  //}
    
  static const int nCombs = 8;
  static const int nAllpasses = 4;
  static const int stereoSpread = 23;
  static const StkFloat fixedGain;
  static const StkFloat scaleWet;
  static const StkFloat scaleDry;
  static const StkFloat scaleDamp;
  static const StkFloat scaleRoom;
  static const StkFloat offsetRoom;

  // Delay line lengths for 44100Hz sampling rate.
  static int cDelayLengths[nCombs];
  static int aDelayLengths[nAllpasses];

  StkFloat g_;        // allpass coefficient
  StkFloat gain_;
  StkFloat roomSizeMem_, roomSize_;
  StkFloat dampMem_, damp_;
  StkFloat wet1_, wet2_;
  StkFloat dry_;
  StkFloat width_;
  bool frozenMode_;

  // LBFC: Lowpass Feedback Comb Filters
  Delay combDelayL_[nCombs];
  Delay combDelayR_[nCombs];
  OnePole combLPL_[nCombs];
  OnePole combLPR_[nCombs];
        
  // AP: Allpass Filters
  Delay allPassDelayL_[nAllpasses];
  Delay allPassDelayR_[nAllpasses];
};

inline StkFloat FreeVerb :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "FreeVerb::lastOut(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

inline StkFloat FreeVerb::tick( StkFloat inputL, StkFloat inputR, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "FreeVerb::tick(): channel argument must be less than 2!";
    handleError(StkError::FUNCTION_ARGUMENT);
  }
#endif

  StkFloat fInput = (inputL + inputR) * gain_;
  StkFloat outL = 0.0;
  StkFloat outR = 0.0;

  // Parallel LBCF filters
  for ( int i = 0; i < nCombs; i++ ) {
    // Left channel
    //StkFloat yn = fInput + (roomSize_ * FreeVerb::undenormalize(combLPL_[i].tick(FreeVerb::undenormalize(combDelayL_[i].nextOut()))));
    StkFloat yn = fInput + (roomSize_ * combLPL_[i].tick( combDelayL_[i].nextOut() ) );
    combDelayL_[i].tick(yn);
    outL += yn;

    // Right channel
    //yn = fInput + (roomSize_ * FreeVerb::undenormalize(combLPR_[i].tick(FreeVerb::undenormalize(combDelayR_[i].nextOut()))));
    yn = fInput + (roomSize_ * combLPR_[i].tick( combDelayR_[i].nextOut() ) );
    combDelayR_[i].tick(yn);
    outR += yn;
  }

  // Series allpass filters
  for ( int i = 0; i < nAllpasses; i++ ) {
    // Left channel
    //StkFloat vn_m = FreeVerb::undenormalize(allPassDelayL_[i].nextOut());
    StkFloat vn_m = allPassDelayL_[i].nextOut();
    StkFloat vn = outL + (g_ * vn_m);
    allPassDelayL_[i].tick(vn);
        
    // calculate output
    outL = -vn + (1.0 + g_)*vn_m;

    // Right channel
    //vn_m = FreeVerb::undenormalize(allPassDelayR_[i].nextOut());
    vn_m = allPassDelayR_[i].nextOut();
    vn = outR + (g_ * vn_m);
    allPassDelayR_[i].tick(vn);

    // calculate output
    outR = -vn + (1.0 + g_)*vn_m;
  }

  // Mix output
  lastFrame_[0] = outL*wet1_ + outR*wet2_ + inputL*dry_;
  lastFrame_[1] = outR*wet1_ + outL*wet2_ + inputR*dry_;

  /*
  // Hard limiter ... there's not much else we can do at this point
  if ( lastFrame_[0] >= 1.0 ) {
    lastFrame_[0] = 0.9999;
  }
  if ( lastFrame_[0] <= -1.0 ) {
    lastFrame_[0] = -0.9999;
  }
  if ( lastFrame_[1] >= 1.0 ) {
    lastFrame_[1] = 0.9999;
  }
  if ( lastFrame_[1] <= -1.0 ) {
    lastFrame_[1] = -0.9999;
  }
  */

  return lastFrame_[channel];
}

}

#endif
