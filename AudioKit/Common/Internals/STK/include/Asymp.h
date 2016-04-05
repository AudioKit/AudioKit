#ifndef STK_ASYMP_H
#define STK_ASYMP_H

#include "Generator.h"

namespace stk {

/***************************************************/
/*! \class Asymp
    \brief STK asymptotic curve envelope class

    This class implements a simple envelope generator
    which asymptotically approaches a target value.
    The algorithm used is of the form:

    y[n] = a y[n-1] + (1-a) target,

    where a = exp(-T/tau), T is the sample period, and
    tau is a time constant.  The user can set the time
    constant (default value = 0.3) and target value.
    Theoretically, this recursion never reaches its
    target, though the calculations in this class are
    stopped when the current value gets within a small
    threshold value of the target (at which time the
    current value is set to the target).  It responds
    to \e keyOn and \e keyOff messages by ramping to
    1.0 on keyOn and to 0.0 on keyOff.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

const StkFloat TARGET_THRESHOLD = 0.000001;

class Asymp : public Generator
{
 public:

  //! Default constructor.
  Asymp( void );

  //! Class destructor.
  ~Asymp( void );

  //! Set target = 1.
  void keyOn( void );

  //! Set target = 0.
  void keyOff( void );

  //! Set the asymptotic rate via the time factor \e tau (must be > 0).
  /*!
    The rate is computed as described above.  The value of \e tau
    must be greater than zero.  Values of \e tau close to zero produce
    fast approach rates, while values greater than 1.0 produce rather
    slow rates.
  */
  void setTau( StkFloat tau );

  //! Set the asymptotic rate based on a time duration (must be > 0).
  void setTime( StkFloat time );

  //! Set the asymptotic rate such that the target value is perceptually reached (to within -60dB of the target) in \e t60 seconds.
  void setT60( StkFloat t60 );

  //! Set the target value.
  void setTarget( StkFloat target );

  //! Set current and target values to \e value.
  void setValue( StkFloat value );

  //! Return the current envelope \e state (0 = at target, 1 otherwise).
  int getState( void ) const { return state_; };

  //! Return the last computed output value.
  StkFloat lastOut( void ) const { return lastFrame_[0]; };

  //! Compute and return one output sample.
  StkFloat tick( void );

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

 protected:

  void sampleRateChanged( StkFloat newRate, StkFloat oldRate );

  StkFloat value_;
  StkFloat target_;
  StkFloat factor_;
  StkFloat constant_;
  int state_;
};

inline StkFloat Asymp :: tick( void )
{
  if ( state_ ) {

    value_ = factor_ * value_ + constant_;

    // Check threshold.
    if ( target_ > value_ ) {
      if ( target_ - value_ <= TARGET_THRESHOLD ) {
        value_ = target_;
        state_ = 0;
      }
    }
    else {
      if ( value_ - target_ <= TARGET_THRESHOLD ) {
        value_ = target_;
        state_ = 0;
      }
    }
    lastFrame_[0] = value_;
  }

  return value_;
}

inline StkFrames& Asymp :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() ) {
    oStream_ << "Asymp::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
    *samples = Asymp::tick();

  return frames;
}

} // stk namespace

#endif
