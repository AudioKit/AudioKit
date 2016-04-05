/***************************************************/
/*! \class Blit
    \brief STK band-limited impulse train class.

    This class generates a band-limited impulse train using a
    closed-form algorithm reported by Stilson and Smith in "Alias-Free
    Digital Synthesis of Classic Analog Waveforms", 1996.  The user
    can specify both the fundamental frequency of the impulse train
    and the number of harmonics contained in the resulting signal.

    The signal is normalized so that the peak value is +/-1.0.

    If nHarmonics is 0, then the signal will contain all harmonics up
    to half the sample rate.  Note, however, that this setting may
    produce aliasing in the signal when the frequency is changing (no
    automatic modification of the number of harmonics is performed by
    the setFrequency() function).

    Original code by Robin Davies, 2005.
    Revisions by Gary Scavone for STK, 2005.
*/
/***************************************************/

#include "Blit.h"

namespace stk {
 
Blit:: Blit( StkFloat frequency )
{
  if ( frequency <= 0.0 ) {
    oStream_ << "Blit::Blit: argument (" << frequency << ") must be positive!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  nHarmonics_ = 0;
  this->setFrequency( frequency );
  this->reset();
}

Blit :: ~Blit()
{
}

void Blit :: reset()
{
  phase_ = 0.0;
  lastFrame_[0] = 0.0;
}

void Blit :: setFrequency( StkFloat frequency )
{
  if ( frequency <= 0.0 ) {
    oStream_ << "Blit::setFrequency: argument (" << frequency << ") must be positive!";
    handleError( StkError::WARNING ); return;
  }

  p_ = Stk::sampleRate() / frequency;
  rate_ = PI / p_;
  this->updateHarmonics();
}

void Blit :: setHarmonics( unsigned int nHarmonics )
{
  nHarmonics_ = nHarmonics;
  this->updateHarmonics();
}

void Blit :: updateHarmonics( void )
{
  if ( nHarmonics_ <= 0 ) {
    unsigned int maxHarmonics = (unsigned int) floor( 0.5 * p_ );
    m_ = 2 * maxHarmonics + 1;
  }
  else
    m_ = 2 * nHarmonics_ + 1;
}

} // stk namespace
