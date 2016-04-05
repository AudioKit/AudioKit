/***************************************************/
/*! \class NRev
    \brief CCRMA's NRev reverberator class.

    This class takes a monophonic input signal and produces a stereo
    output signal.  It is derived from the CLM NRev function, which is
    based on the use of networks of simple allpass and comb delay
    filters.  This particular arrangement consists of 6 comb filters
    in parallel, followed by 3 allpass filters, a lowpass filter, and
    another allpass in series, followed by two allpass filters in
    parallel with corresponding right and left outputs.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "NRev.h"
#include <cmath>

namespace stk {

NRev :: NRev( StkFloat T60 )
{
  if ( T60 <= 0.0 ) {
    oStream_ << "NRev::NRev: argument (" << T60 << ") must be positive!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  lastFrame_.resize( 1, 2, 0.0 ); // resize lastFrame_ for stereo output

  int lengths[15] = {1433, 1601, 1867, 2053, 2251, 2399, 347, 113, 37, 59, 53, 43, 37, 29, 19};
  double scaler = Stk::sampleRate() / 25641.0;

  int delay, i;
  for ( i=0; i<15; i++ ) {
    delay = (int) floor(scaler * lengths[i]);
    if ( (delay & 1) == 0) delay++;
    while ( !this->isPrime(delay) ) delay += 2;
    lengths[i] = delay;
  }

  for ( i=0; i<6; i++ ) {
    combDelays_[i].setMaximumDelay( lengths[i] );
    combDelays_[i].setDelay( lengths[i] );
    combCoefficient_[i] = pow(10.0, (-3 * lengths[i] / (T60 * Stk::sampleRate())));
  }

  for ( i=0; i<8; i++ ) {
	  allpassDelays_[i].setMaximumDelay( lengths[i+6] );
	  allpassDelays_[i].setDelay( lengths[i+6] );
  }

  this->setT60( T60 );
  allpassCoefficient_ = 0.7;
  effectMix_ = 0.3;
  this->clear();
}

void NRev :: clear()
{
  int i;
  for (i=0; i<6; i++) combDelays_[i].clear();
  for (i=0; i<8; i++) allpassDelays_[i].clear();
  lastFrame_[0] = 0.0;
  lastFrame_[1] = 0.0;
  lowpassState_ = 0.0;
}

void NRev :: setT60( StkFloat T60 )
{
  if ( T60 <= 0.0 ) {
    oStream_ << "NRev::setT60: argument (" << T60 << ") must be positive!";
    handleError( StkError::WARNING ); return;
  }

  for ( int i=0; i<6; i++ )
    combCoefficient_[i] = pow(10.0, (-3.0 * combDelays_[i].getDelay() / (T60 * Stk::sampleRate())));
}

StkFrames& NRev :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() - 1 ) {
    oStream_ << "NRev::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = tick( *samples );
    *(samples+1) = lastFrame_[1];
  }

  return frames;
}

StkFrames& NRev :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() - 1 ) {
    oStream_ << "NRev::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels(), oHop = oFrames.channels();
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop ) {
    *oSamples = tick( *iSamples );
    *(oSamples+1) = lastFrame_[1];
  }

  return iFrames;
}

} // stk namespace
