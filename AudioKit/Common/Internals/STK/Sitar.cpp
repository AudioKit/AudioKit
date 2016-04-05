/***************************************************/
/*! \class Sitar
    \brief STK sitar string model class.

    This class implements a sitar plucked string
    physical model based on the Karplus-Strong
    algorithm.

    This is a digital waveguide model, making its
    use possibly subject to patents held by
    Stanford University, Yamaha, and others.
    There exist at least two patents, assigned to
    Stanford, bearing the names of Karplus and/or
    Strong.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Sitar.h"

namespace stk {

Sitar :: Sitar( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Sitar::Sitar: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  unsigned long length = (unsigned long) ( Stk::sampleRate() / lowestFrequency + 1 );
  delayLine_.setMaximumDelay( length );
  delay_ = 0.5 * length;
  delayLine_.setDelay( delay_ );
  targetDelay_ = delay_;

  loopFilter_.setZero( 0.01 );
  loopGain_ = 0.999;

  envelope_.setAllTimes( 0.001, 0.04, 0.0, 0.5 );
  this->clear();
}

Sitar :: ~Sitar( void )
{
}

void Sitar :: clear( void )
{
  delayLine_.clear();
  loopFilter_.clear();
}

void Sitar :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Sitar::setFrequency: parameter is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  targetDelay_ = (Stk::sampleRate() / frequency);
  delay_ = targetDelay_ * (1.0 + (0.05 * noise_.tick()));
  delayLine_.setDelay( delay_ );
  loopGain_ = 0.995 + (frequency * 0.0000005);
  if ( loopGain_ > 0.9995 ) loopGain_ = 0.9995;
}

void Sitar :: pluck( StkFloat amplitude )
{
  envelope_.keyOn();
}

void Sitar :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->pluck( amplitude );
  amGain_ = 0.1 * amplitude;
}

void Sitar :: noteOff( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Sitar::noteOff: amplitude is out of range!";
    handleError( StkError::WARNING ); return;
  }

  loopGain_ = (StkFloat) 1.0 - amplitude;
}

} // stk namespace
