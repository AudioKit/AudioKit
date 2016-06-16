/***************************************************/
/*! \class Envelope
    \brief STK linear line envelope class.

    This class implements a simple linear line envelope generator
    which is capable of ramping to an arbitrary target value by a
    specified \e rate.  It also responds to simple \e keyOn and \e
    keyOff messages, ramping to 1.0 on keyOn and to 0.0 on keyOff.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Envelope.h"

namespace stk {

Envelope :: Envelope( void ) : Generator()
{    
  target_ = 0.0;
  value_ = 0.0;
  rate_ = 0.001;
  state_ = 0;
  Stk::addSampleRateAlert( this );
}

Envelope :: ~Envelope( void )
{
  Stk::removeSampleRateAlert( this );
}

Envelope& Envelope :: operator= ( const Envelope& e )
{
  if ( this != &e ) {
    target_ = e.target_;
    value_ = e.value_;
    rate_ = e.rate_;
    state_ = e.state_;
  }

  return *this;
}

void Envelope :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ )
    rate_ = oldRate * rate_ / newRate;
}

void Envelope :: setRate( StkFloat rate )
{
  if ( rate < 0.0 ) {
    oStream_ << "Envelope::setRate: argument must be >= 0.0!";
    handleError( StkError::WARNING ); return;
  }

  rate_ = rate;
}

void Envelope :: setTime( StkFloat time )
{
  if ( time <= 0.0 ) {
    oStream_ << "Envelope::setTime: argument must be > 0.0!";
    handleError( StkError::WARNING ); return;
  }

  rate_ = 1.0 / ( time * Stk::sampleRate() );
}

void Envelope :: setTarget( StkFloat target )
{
  target_ = target;
  if ( value_ != target_ ) state_ = 1;
}

void Envelope :: setValue( StkFloat value )
{
  state_ = 0;
  target_ = value;
  value_ = value;
  lastFrame_[0] = value_;
}

} // stk namespace
