/***************************************************/
/*! \class PRCRev
    \brief Perry's simple reverberator class.

    This class is based on some of the famous
    Stanford/CCRMA reverbs (NRev, KipRev), which
    were based on the Chowning/Moorer/Schroeder
    reverberators using networks of simple allpass
    and comb delay filters.  This class implements
    two series allpass units and two parallel comb
    filters.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "PRCRev.h"
#include <cmath>

namespace stk {

PRCRev :: PRCRev( StkFloat T60 )
{
  if ( T60 <= 0.0 ) {
    oStream_ << "PRCRev::PRCRev: argument (" << T60 << ") must be positive!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  lastFrame_.resize( 1, 2, 0.0 ); // resize lastFrame_ for stereo output

  // Delay lengths for 44100 Hz sample rate.
  int lengths[4]= {341, 613, 1557, 2137};
  double scaler = Stk::sampleRate() / 44100.0;

  // Scale the delay lengths if necessary.
  int delay, i;
  if ( scaler != 1.0 ) {
    for (i=0; i<4; i++)	{
      delay = (int) floor(scaler * lengths[i]);
      if ( (delay & 1) == 0) delay++;
      while ( !this->isPrime(delay) ) delay += 2;
      lengths[i] = delay;
    }
  }

  for ( i=0; i<2; i++ )	{
	  allpassDelays_[i].setMaximumDelay( lengths[i] );
	  allpassDelays_[i].setDelay( lengths[i] );

    combDelays_[i].setMaximumDelay( lengths[i+2] );
    combDelays_[i].setDelay( lengths[i+2] );
  }

  this->setT60( T60 );
  allpassCoefficient_ = 0.7;
  effectMix_ = 0.5;
  this->clear();
}

void PRCRev :: clear( void )
{
  allpassDelays_[0].clear();
  allpassDelays_[1].clear();
  combDelays_[0].clear();
  combDelays_[1].clear();
  lastFrame_[0] = 0.0;
  lastFrame_[1] = 0.0;
}

void PRCRev :: setT60( StkFloat T60 )
{
  if ( T60 <= 0.0 ) {
    oStream_ << "PRCRev::setT60: argument (" << T60 << ") must be positive!";
    handleError( StkError::WARNING ); return;
  }

  combCoefficient_[0] = pow(10.0, (-3.0 * combDelays_[0].getDelay() / (T60 * Stk::sampleRate())));
  combCoefficient_[1] = pow(10.0, (-3.0 * combDelays_[1].getDelay() / (T60 * Stk::sampleRate())));
}

StkFrames& PRCRev :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() - 1 ) {
    oStream_ << "PRCRev::tick(): channel and StkFrames arguments are incompatible!";
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

StkFrames& PRCRev :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() - 1 ) {
    oStream_ << "PRCRev::tick(): channel and StkFrames arguments are incompatible!";
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
