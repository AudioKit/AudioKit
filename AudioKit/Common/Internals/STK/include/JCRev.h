#ifndef STK_JCREV_H
#define STK_JCREV_H

#include "Effect.h"
#include "Delay.h"
#include "OnePole.h"

namespace stk {

/***************************************************/
/*! \class JCRev
    \brief John Chowning's reverberator class.

    This class takes a monophonic input signal and
    produces a stereo output signal.  It is derived
    from the CLM JCRev function, which is based on
    the use of networks of simple allpass and comb
    delay filters.  This class implements three
    series allpass units, followed by four parallel
    comb filters, and two decorrelation delay lines
    in parallel at the output.

    Although not in the original JC reverberator,
    one-pole lowpass filters have been added inside
    the feedback comb filters.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class JCRev : public Effect
{
 public:
  //! Class constructor taking a T60 decay time argument (one second default value).
  JCRev( StkFloat T60 = 1.0 );

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

  Delay allpassDelays_[3];
  Delay combDelays_[4];
  OnePole combFilters_[4];
  Delay outLeftDelay_;
  Delay outRightDelay_;
  StkFloat allpassCoefficient_;
  StkFloat combCoefficient_[4];

};

inline StkFloat JCRev :: lastOut( unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "JCRev::lastOut(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  return lastFrame_[channel];
}

inline StkFloat JCRev :: tick( StkFloat input, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel > 1 ) {
    oStream_ << "JCRev::tick(): channel argument must be less than 2!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat temp, temp0, temp1, temp2, temp3, temp4, temp5, temp6;
  StkFloat filtout;

  temp = allpassDelays_[0].lastOut();
  temp0 = allpassCoefficient_ * temp;
  temp0 += input;
  allpassDelays_[0].tick(temp0);
  temp0 = -(allpassCoefficient_ * temp0) + temp;
    
  temp = allpassDelays_[1].lastOut();
  temp1 = allpassCoefficient_ * temp;
  temp1 += temp0;
  allpassDelays_[1].tick(temp1);
  temp1 = -(allpassCoefficient_ * temp1) + temp;
    
  temp = allpassDelays_[2].lastOut();
  temp2 = allpassCoefficient_ * temp;
  temp2 += temp1;
  allpassDelays_[2].tick(temp2);
  temp2 = -(allpassCoefficient_ * temp2) + temp;
    
  temp3 = temp2 + ( combFilters_[0].tick( combCoefficient_[0] * combDelays_[0].lastOut() ) );
  temp4 = temp2 + ( combFilters_[1].tick( combCoefficient_[1] * combDelays_[1].lastOut() ) );
  temp5 = temp2 + ( combFilters_[2].tick( combCoefficient_[2] * combDelays_[2].lastOut() ) );
  temp6 = temp2 + ( combFilters_[3].tick( combCoefficient_[3] * combDelays_[3].lastOut() ) );

  combDelays_[0].tick(temp3);
  combDelays_[1].tick(temp4);
  combDelays_[2].tick(temp5);
  combDelays_[3].tick(temp6);

  filtout = temp3 + temp4 + temp5 + temp6;

  lastFrame_[0] = effectMix_ * (outLeftDelay_.tick(filtout));
  lastFrame_[1] = effectMix_ * (outRightDelay_.tick(filtout));
  temp = (1.0 - effectMix_) * input;
  lastFrame_[0] += temp;
  lastFrame_[1] += temp;
    
  return 0.7 * lastFrame_[channel];
}

} // stk namespace

#endif

