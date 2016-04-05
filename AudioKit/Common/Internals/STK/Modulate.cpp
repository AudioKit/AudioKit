/***************************************************/
/*! \class Modulate
    \brief STK periodic/random modulator.

    This class combines random and periodic
    modulations to give a nice, natural human
    modulation function.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Modulate.h"

namespace stk {

Modulate :: Modulate( void )
{
  vibrato_.setFrequency( 6.0 );
  vibratoGain_ = 0.04;

  noiseRate_ = (unsigned int) ( 330.0 * Stk::sampleRate() / 22050.0 );
  noiseCounter_ = noiseRate_;

  randomGain_ = 0.05;
  filter_.setPole( 0.999 );
  filter_.setGain( randomGain_ );

  Stk::addSampleRateAlert( this );
}

Modulate :: ~Modulate( void )
{
  Stk::removeSampleRateAlert( this );
}

void Modulate :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ )
    noiseRate_ = (unsigned int ) ( newRate * noiseRate_ / oldRate );
}

void Modulate :: setRandomGain( StkFloat gain )
{
  randomGain_ = gain;
  filter_.setGain( randomGain_ );
}

} // stk namespace
