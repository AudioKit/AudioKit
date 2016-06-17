/***************************************************/
/*! \class Sampler
    \brief STK sampling synthesis abstract base class.

    This instrument provides an ADSR envelope, a one-pole filter, and
    structures for an arbitrary number of attack and looped files.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Sampler.h"

namespace stk {

Sampler :: Sampler( void )
{
  // We don't make the waves here yet, because
  // we don't know what they will be.
  baseFrequency_ = 440.0;
  attackGain_ = 0.25;
  loopGain_ = 0.25;
}  

Sampler :: ~Sampler( void )
{
  unsigned int i;
  for ( i=0; i<attacks_.size(); i++ ) delete attacks_[i];
  for ( i=0; i<loops_.size(); i++ ) delete loops_[i];
}

void Sampler :: keyOn( void )
{
  // Reset all attack waves.
  for ( unsigned int i=0; i<attacks_.size(); i++ )
    attacks_[i]->reset();

  // Start the envelope.
  adsr_.keyOn();

}

void Sampler :: keyOff( void )
{
  adsr_.keyOff();
}

void Sampler :: noteOff( StkFloat amplitude )
{
  this->keyOff();
}

} // stk namespace
