#ifndef STK_NREV_H
#define STK_NREV_H

#include "Effect.h"
#include "Delay.h"

namespace stk {

/***************************************************/
/*! \class NRev
    \brief CCRMA's NRev reverberator class.

    This class takes a monophonic input signal and produces a stereo
    output signal.  It is derived from the CLM NRev function, which is
    based on the use of networks of simple allpass and comb delay
    filters.  This particular arrangement consists of 6 comb filters
    in parallel, followed by 3 allpass filters, a lowpass filter, and
    another allpass in series, followed by two allpass filters in
    parallel with corresponding right and left outputs.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class NRev : public Effect
{
 public:
  //! Class constructor taking a T60 decay time argument (one second default value).
  NRev( StkFloat T60 = 1.0 );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set the reverberation T60 decay time.
  void setT60( StkFloat T60 );

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

  Delay allpassDelays_[8];
  Delay combDelays_[6];
  StkFloat allpassCoefficient_;
  StkFloat combCoefficient_[6];
	StkFloat lowpassState_;

};

inline StkFloat NRev :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "NRev::lastOut(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

inline StkFloat NRev :: tick( StkFloat input, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "NRev::tick(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat temp, temp0, temp1, temp2, temp3;
  int i;

  temp0 = 0.0;
  for ( i=0; i<6; i++ ) {
    temp = input + (combCoefficient_[i] * combDelays_[i].lastOut());
    temp0 += combDelays_[i].tick(temp);
  }

  for ( i=0; i<3; i++ )	{
    temp = allpassDelays_[i].lastOut();
    temp1 = allpassCoefficient_ * temp;
    temp1 += temp0;
    allpassDelays_[i].tick(temp1);
    temp0 = -(allpassCoefficient_ * temp1) + temp;
  }

	// One-pole lowpass filter.
  lowpassState_ = 0.7 * lowpassState_ + 0.3 * temp0;
  temp = allpassDelays_[3].lastOut();
  temp1 = allpassCoefficient_ * temp;
  temp1 += lowpassState_;
  allpassDelays_[3].tick( temp1 );
  temp1 = -( allpassCoefficient_ * temp1 ) + temp;
    
  temp = allpassDelays_[4].lastOut();
  temp2 = allpassCoefficient_ * temp;
  temp2 += temp1;
  allpassDelays_[4].tick( temp2 );
  lastFrame_[0] = effectMix_*( -( allpassCoefficient_ * temp2 ) + temp );
    
  temp = allpassDelays_[5].lastOut();
  temp3 = allpassCoefficient_ * temp;
  temp3 += temp1;
  allpassDelays_[5].tick( temp3 );
  lastFrame_[1] = effectMix_*( - ( allpassCoefficient_ * temp3 ) + temp );

  temp = ( 1.0 - effectMix_ ) * input;
  lastFrame_[0] += temp;
  lastFrame_[1] += temp;
    
  return lastFrame_[channel];
}

} // stk namespace

#endif

