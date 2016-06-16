/***************************************************/
/*! \class BiQuad
    \brief STK biquad (two-pole, two-zero) filter class.

    This class implements a two-pole, two-zero digital filter.
    Methods are provided for creating a resonance or notch in the
    frequency response while maintaining a constant filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "BiQuad.h"
#include <cmath>

namespace stk {

BiQuad :: BiQuad() : Filter()
{
  b_.resize( 3, 0.0 );
  a_.resize( 3, 0.0 );
  b_[0] = 1.0;
  a_[0] = 1.0;
  inputs_.resize( 3, 1, 0.0 );
  outputs_.resize( 3, 1, 0.0 );

  Stk::addSampleRateAlert( this );
}

BiQuad :: ~BiQuad()
{
  Stk::removeSampleRateAlert( this );
}

void BiQuad :: setCoefficients( StkFloat b0, StkFloat b1, StkFloat b2, StkFloat a1, StkFloat a2, bool clearState )
{
  b_[0] = b0;
  b_[1] = b1;
  b_[2] = b2;
  a_[1] = a1;
  a_[2] = a2;

  if ( clearState ) this->clear();
}

void BiQuad :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ ) {
    oStream_ << "BiQuad::sampleRateChanged: you may need to recompute filter coefficients!";
    handleError( StkError::WARNING );
  }
}

void BiQuad :: setResonance( StkFloat frequency, StkFloat radius, bool normalize )
{
#if defined(_STK_DEBUG_)
  if ( frequency < 0.0 || frequency > 0.5 * Stk::sampleRate() ) {
    oStream_ << "BiQuad::setResonance: frequency argument (" << frequency << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
  if ( radius < 0.0 || radius >= 1.0 ) {
    oStream_ << "BiQuad::setResonance: radius argument (" << radius << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  a_[2] = radius * radius;
  a_[1] = -2.0 * radius * cos( TWO_PI * frequency / Stk::sampleRate() );

  if ( normalize ) {
    // Use zeros at +- 1 and normalize the filter peak gain.
    b_[0] = 0.5 - 0.5 * a_[2];
    b_[1] = 0.0;
    b_[2] = -b_[0];
  }
}

void BiQuad :: setNotch( StkFloat frequency, StkFloat radius )
{
#if defined(_STK_DEBUG_)
  if ( frequency < 0.0 || frequency > 0.5 * Stk::sampleRate() ) {
    oStream_ << "BiQuad::setNotch: frequency argument (" << frequency << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
  if ( radius < 0.0 ) {
    oStream_ << "BiQuad::setNotch: radius argument (" << radius << ") is negative!";
    handleError( StkError::WARNING ); return;
  }
#endif

  // This method does not attempt to normalize the filter gain.
  b_[2] = radius * radius;
  b_[1] = (StkFloat) -2.0 * radius * cos( TWO_PI * (double) frequency / Stk::sampleRate() );
}

void BiQuad :: setEqualGainZeroes( void )
{
  b_[0] = 1.0;
  b_[1] = 0.0;
  b_[2] = -1.0;
}

} // stk namespace
