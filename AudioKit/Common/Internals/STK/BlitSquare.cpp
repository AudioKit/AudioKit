/***************************************************/
/*! \class BlitSquare
    \brief STK band-limited square wave class.

    This class generates a band-limited square wave signal.  It is
    derived in part from the approach reported by Stilson and Smith in
    "Alias-Free Digital Synthesis of Classic Analog Waveforms", 1996.
    The algorithm implemented in this class uses a SincM function with
    an even M value to achieve a bipolar bandlimited impulse train.
    This signal is then integrated to achieve a square waveform.  The
    integration process has an associated DC offset so a DC blocking
    filter is applied at the output.

    The user can specify both the fundamental frequency of the
    waveform and the number of harmonics contained in the resulting
    signal.

    If nHarmonics is 0, then the signal will contain all harmonics up
    to half the sample rate.  Note, however, that this setting may
    produce aliasing in the signal when the frequency is changing (no
    automatic modification of the number of harmonics is performed by
    the setFrequency() function).  Also note that the harmonics of a
    square wave fall at odd integer multiples of the fundamental, so
    aliasing will happen with a lower fundamental than with the other
    Blit waveforms.  This class is not guaranteed to be well behaved
    in the presence of significant aliasing.

    Based on initial code of Robin Davies, 2005
    Modified algorithm code by Gary Scavone, 2005 - 2010.
*/
/***************************************************/

#include "BlitSquare.h"

namespace stk {

BlitSquare:: BlitSquare( StkFloat frequency )
{
  if ( frequency <= 0.0 ) {
    oStream_ << "BlitSquare::BlitSquare: argument (" << frequency << ") must be positive!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  nHarmonics_ = 0;
  this->setFrequency( frequency );
  this->reset();
}

BlitSquare :: ~BlitSquare()
{
}

void BlitSquare :: reset()
{
  phase_ = 0.0;
  lastFrame_[0] = 0.0;
  dcbState_ = 0.0;
  lastBlitOutput_ = 0;
}

void BlitSquare :: setFrequency( StkFloat frequency )
{
  if ( frequency <= 0.0 ) {
    oStream_ << "BlitSquare::setFrequency: argument (" << frequency << ") must be positive!";
    handleError( StkError::WARNING ); return;
  }

  // By using an even value of the parameter M, we get a bipolar blit
  // waveform at half the blit frequency.  Thus, we need to scale the
  // frequency value here by 0.5. (GPS, 2006).
  p_ = 0.5 * Stk::sampleRate() / frequency;
  rate_ = PI / p_;
  this->updateHarmonics();
}

void BlitSquare :: setHarmonics( unsigned int nHarmonics )
{
  nHarmonics_ = nHarmonics;
  this->updateHarmonics();
}

void BlitSquare :: updateHarmonics( void )
{
  // Make sure we end up with an even value of the parameter M here.
  if ( nHarmonics_ <= 0 ) {
    unsigned int maxHarmonics = (unsigned int) floor( 0.5 * p_ );
    m_ = 2 * (maxHarmonics + 1);
  }
  else
    m_ = 2 * (nHarmonics_ + 1);

  a_ = m_ / p_;
}

} // stk namespace
