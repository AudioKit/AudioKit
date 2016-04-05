/***************************************************/
/*! \class ADSR
    \brief STK ADSR envelope class.

   This class implements a traditional ADSR (Attack, Decay, Sustain,
    Release) envelope.  It responds to simple keyOn and keyOff
    messages, keeping track of its state.  The \e state = ADSR::IDLE
    before being triggered and after the envelope value reaches 0.0 in
    the ADSR::RELEASE state.  All rate, target and level settings must
    be non-negative.  All time settings must be positive.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "ADSR.h"

namespace stk {

ADSR :: ADSR( void )
{
  target_ = 0.0;
  value_ = 0.0;
  attackRate_ = 0.001;
  decayRate_ = 0.001;
  releaseRate_ = 0.005;
  releaseTime_ = -1.0;
  sustainLevel_ = 0.5;
  state_ = IDLE;
  Stk::addSampleRateAlert( this );
}

ADSR :: ~ADSR( void )
{
  Stk::removeSampleRateAlert( this );
}

void ADSR :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ ) {
    attackRate_ = oldRate * attackRate_ / newRate;
    decayRate_ = oldRate * decayRate_ / newRate;
    releaseRate_ = oldRate * releaseRate_ / newRate;
  }
}

void ADSR :: keyOn()
{
  if ( target_ <= 0.0 ) target_ = 1.0;
  state_ = ATTACK;
}

void ADSR :: keyOff()
{
  target_ = 0.0;
  state_ = RELEASE;

  // FIXED October 2010 - Nick Donaldson
  // Need to make release rate relative to current value!!
  // Only update if we have set a TIME rather than a RATE,
  // in which case releaseTime_ will be -1
  if ( releaseTime_ > 0.0 )
	  releaseRate_ = value_ / ( releaseTime_ * Stk::sampleRate() );
}

void ADSR :: setAttackRate( StkFloat rate )
{
  if ( rate < 0.0 ) {
    oStream_ << "ADSR::setAttackRate: argument must be >= 0.0!";
    handleError( StkError::WARNING ); return;
  }

  attackRate_ = rate;
}

void ADSR :: setAttackTarget( StkFloat target )
{
  if ( target < 0.0 ) {
    oStream_ << "ADSR::setAttackTarget: negative target not allowed!";
    handleError( StkError::WARNING ); return;
  }

  target_ = target;
}

void ADSR :: setDecayRate( StkFloat rate )
{
  if ( rate < 0.0 ) {
    oStream_ << "ADSR::setDecayRate: negative rates not allowed!";
    handleError( StkError::WARNING ); return;
  }

  decayRate_ = rate;
}

void ADSR :: setSustainLevel( StkFloat level )
{
  if ( level < 0.0 ) {
    oStream_ << "ADSR::setSustainLevel: negative level not allowed!";
    handleError( StkError::WARNING ); return;
  }

  sustainLevel_ = level;
}

void ADSR :: setReleaseRate( StkFloat rate )
{
  if ( rate < 0.0 ) {
    oStream_ << "ADSR::setReleaseRate: negative rates not allowed!";
    handleError( StkError::WARNING ); return;
  }

  releaseRate_ = rate;

  // Set to negative value so we don't update the release rate on keyOff()
  releaseTime_ = -1.0;
}

void ADSR :: setAttackTime( StkFloat time )
{
  if ( time <= 0.0 ) {
    oStream_ << "ADSR::setAttackTime: negative or zero times not allowed!";
    handleError( StkError::WARNING ); return;
  }

  attackRate_ = 1.0 / ( time * Stk::sampleRate() );
}

void ADSR :: setDecayTime( StkFloat time )
{
  if ( time <= 0.0 ) {
    oStream_ << "ADSR::setDecayTime: negative or zero times not allowed!";
    handleError( StkError::WARNING ); return;
  }

  decayRate_ = (1.0 - sustainLevel_) / ( time * Stk::sampleRate() );
}

void ADSR :: setReleaseTime( StkFloat time )
{
  if ( time <= 0.0 ) {
    oStream_ << "ADSR::setReleaseTime: negative or zero times not allowed!";
    handleError( StkError::WARNING ); return;
  }

  releaseRate_ = sustainLevel_ / ( time * Stk::sampleRate() );
  releaseTime_ = time;
}

void ADSR :: setAllTimes( StkFloat aTime, StkFloat dTime, StkFloat sLevel, StkFloat rTime )
{
  this->setAttackTime( aTime );
  this->setSustainLevel( sLevel );
  this->setDecayTime( dTime );
  this->setReleaseTime( rTime );
}

void ADSR :: setTarget( StkFloat target )
{
  if ( target < 0.0 ) {
    oStream_ << "ADSR::setTarget: negative target not allowed!";
    handleError( StkError::WARNING ); return;
  }

  target_ = target;

  this->setSustainLevel( target_ );
  if ( value_ < target_ ) state_ = ATTACK;
  if ( value_ > target_ ) state_ = DECAY;
}

void ADSR :: setValue( StkFloat value )
{
  state_ = SUSTAIN;
  target_ = value;
  value_ = value;
  this->setSustainLevel( value );
  lastFrame_[0] = value;
}

} // stk namespace
