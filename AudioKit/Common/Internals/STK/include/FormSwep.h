#ifndef STK_FORMSWEP_H
#define STK_FORMSWEP_H

#include "Filter.h"

namespace stk {

/***************************************************/
/*! \class FormSwep
    \brief STK sweepable formant filter class.

    This class implements a formant (resonance) which can be "swept"
    over time from one frequency setting to another.  It provides
    methods for controlling the sweep rate and target frequency.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class FormSwep : public Filter
{
 public:

  //! Default constructor creates a second-order pass-through filter.
  FormSwep( void );

  //! Class destructor.
  ~FormSwep();

  //! A function to enable/disable the automatic updating of class data when the STK sample rate changes.
  void ignoreSampleRateChange( bool ignore = true ) { ignoreSampleRateChange_ = ignore; };

  //! Sets the filter coefficients for a resonance at \e frequency (in Hz).
  /*!
    This method determines the filter coefficients corresponding to
    two complex-conjugate poles with the given \e frequency (in Hz)
    and \e radius from the z-plane origin.  The filter zeros are
    placed at z = 1, z = -1, and the coefficients are then normalized
    to produce a constant unity gain (independent of the filter \e
    gain parameter).  The resulting filter frequency response has a
    resonance at the given \e frequency.  The closer the poles are to
    the unit-circle (\e radius close to one), the narrower the
    resulting resonance width.  An unstable filter will result for \e
    radius >= 1.0.  The \e frequency value should be between zero and
    half the sample rate.
  */
  void setResonance( StkFloat frequency, StkFloat radius );

  //! Set both the current and target resonance parameters.
  void setStates( StkFloat frequency, StkFloat radius, StkFloat gain = 1.0 );

  //! Set target resonance parameters.
  void setTargets( StkFloat frequency, StkFloat radius, StkFloat gain = 1.0 );

  //! Set the sweep rate (between 0.0 - 1.0).
  /*!
    The formant parameters are varied in increments of the
    sweep rate between their current and target values.
    A sweep rate of 1.0 will produce an immediate change in
    resonance parameters from their current values to the
    target values.  A sweep rate of 0.0 will produce no
    change in resonance parameters.  
  */
  void setSweepRate( StkFloat rate );

  //! Set the sweep rate in terms of a time value in seconds.
  /*!
    This method adjusts the sweep rate based on a
    given time for the formant parameters to reach
    their target values.
  */
  void setSweepTime( StkFloat time );

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Input one sample to the filter and return a reference to one output.
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

  bool dirty_;
  StkFloat frequency_;
  StkFloat radius_;
  StkFloat startFrequency_;
  StkFloat startRadius_;
  StkFloat startGain_;
  StkFloat targetFrequency_;
  StkFloat targetRadius_;
  StkFloat targetGain_;
  StkFloat deltaFrequency_;
  StkFloat deltaRadius_;
  StkFloat deltaGain_;
  StkFloat sweepState_;
  StkFloat sweepRate_;

};

inline StkFloat FormSwep :: tick( StkFloat input )
{                                     
  if ( dirty_ )  {
    sweepState_ += sweepRate_;
    if ( sweepState_ >= 1.0 )   {
      sweepState_ = 1.0;
      dirty_ = false;
      radius_ = targetRadius_;
      frequency_ = targetFrequency_;
      gain_ = targetGain_;
    }
    else {
      radius_ = startRadius_ + (deltaRadius_ * sweepState_);
      frequency_ = startFrequency_ + (deltaFrequency_ * sweepState_);
      gain_ = startGain_ + (deltaGain_ * sweepState_);
    }
    this->setResonance( frequency_, radius_ );
  }

  inputs_[0] = gain_ * input;
  lastFrame_[0] = b_[0] * inputs_[0] + b_[1] * inputs_[1] + b_[2] * inputs_[2];
  lastFrame_[0] -= a_[2] * outputs_[2] + a_[1] * outputs_[1];
  inputs_[2] = inputs_[1];
  inputs_[1] = inputs_[0];
  outputs_[2] = outputs_[1];
  outputs_[1] = lastFrame_[0];

  return lastFrame_[0];
}

inline StkFrames& FormSwep :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "FormSwep::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = tick( *samples );

  return frames;
}

inline StkFrames& FormSwep :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() ) {
    oStream_ << "FormSwep::tick(): channel and StkFrames arguments are incompatible!";
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
