/***************************************************/
/*! \class TwoZero
    \brief STK two-zero filter class.

    This class implements a two-zero digital filter.  A method is
    provided for creating a "notch" in the frequency response while
    maintaining a constant filter gain.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "TwoZero.h"
#include <cmath>

namespace stk {

TwoZero :: TwoZero( void )
{
  b_.resize( 3, 0.0 );
  inputs_.resize( 3, 1, 0.0 );
  b_[0] = 1.0;

  Stk::addSampleRateAlert( this );
}

TwoZero :: ~TwoZero()
{
  Stk::removeSampleRateAlert( this );
}

void TwoZero :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ ) {
    oStream_ << "TwoZero::sampleRateChanged: you may need to recompute filter coefficients!";
    handleError( StkError::WARNING );
  }
}

void TwoZero :: setCoefficients( StkFloat b0, StkFloat b1, StkFloat b2, bool clearState )
{
  b_[0] = b0;
  b_[1] = b1;
  b_[2] = b2;

  if ( clearState ) this->clear();
}

void TwoZero :: setNotch( StkFloat frequency, StkFloat radius )
{
#if defined(_STK_DEBUG_)
  if ( frequency < 0.0 || frequency > 0.5 * Stk::sampleRate() ) {
    oStream_ << "TwoZero::setNotch: frequency argument (" << frequency << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
  if ( radius < 0.0 ) {
    oStream_ << "TwoZero::setNotch: radius argument (" << radius << ") is negative!";
    handleError( StkError::WARNING ); return;
  }
#endif

  b_[2] = radius * radius;
  b_[1] = -2.0 * radius * cos(TWO_PI * frequency / Stk::sampleRate());

  // Normalize the filter gain.
  if ( b_[1] > 0.0 ) // Maximum at z = 0.
    b_[0] = 1.0 / ( 1.0 + b_[1] + b_[2] );
  else            // Maximum at z = -1.
    b_[0] = 1.0 / ( 1.0 - b_[1] + b_[2] );
  b_[1] *= b_[0];
  b_[2] *= b_[0];
}

} // stk namespace
