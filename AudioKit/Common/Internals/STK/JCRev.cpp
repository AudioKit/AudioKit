/***************************************************/
/*! \class JCRev
    \brief John Chowning's reverberator class.

    This class takes a monophonic input signal and
    produces a stereo output signal.  It is derived
    from the CLM JCRev function, which is based on
    the use of networks of simple allpass and comb
    delay filters.  This class implements three
    series allpass units, followed by four parallel
    comb filters, and two decorrelation delay lines
    in parallel at the output.

    Although not in the original JC reverberator,
    one-pole lowpass filters have been added inside
    the feedback comb filters.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "JCRev.h"
#include <cmath>

namespace stk {

JCRev :: JCRev( StkFloat T60 )
{
  if ( T60 <= 0.0 ) {
    oStream_ << "JCRev::JCRev: argument (" << T60 << ") must be positive!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  lastFrame_.resize( 1, 2, 0.0 ); // resize lastFrame_ for stereo output

  // Delay lengths for 44100 Hz sample rate.
  int lengths[9] = {1116, 1356, 1422, 1617, 225, 341, 441, 211, 179};
  double scaler = Stk::sampleRate() / 44100.0;

  int delay, i;
  if ( scaler != 1.0 ) {
    for ( i=0; i<9; i++ ) {
      delay = (int) floor( scaler * lengths[i] );
      if ( (delay & 1) == 0) delay++;
      while ( !this->isPrime(delay) ) delay += 2;
      lengths[i] = delay;
    }
  }

  for ( i=0; i<3; i++ ) {
	  allpassDelays_[i].setMaximumDelay( lengths[i+4] );
	  allpassDelays_[i].setDelay( lengths[i+4] );
  }

  for ( i=0; i<4; i++ ) {
    combDelays_[i].setMaximumDelay( lengths[i] );
    combDelays_[i].setDelay( lengths[i] );
    combFilters_[i].setPole( 0.2 );
  }

  this->setT60( T60 );
  outLeftDelay_.setMaximumDelay( lengths[7] );
  outLeftDelay_.setDelay( lengths[7] );
  outRightDelay_.setMaximumDelay( lengths[8] );
  outRightDelay_.setDelay( lengths[8] );
  allpassCoefficient_ = 0.7;
  effectMix_ = 0.3;
  this->clear();
}

void JCRev :: clear()
{
  allpassDelays_[0].clear();
  allpassDelays_[1].clear();
  allpassDelays_[2].clear();
  combDelays_[0].clear();
  combDelays_[1].clear();
  combDelays_[2].clear();
  combDelays_[3].clear();
  outRightDelay_.clear();
  outLeftDelay_.clear();
  lastFrame_[0] = 0.0;
  lastFrame_[1] = 0.0;
}

void JCRev :: setT60( StkFloat T60 )
{
  if ( T60 <= 0.0 ) {
    oStream_ << "JCRev::setT60: argument (" << T60 << ") must be positive!";
    handleError( StkError::WARNING ); return;
  }

  for ( int i=0; i<4; i++ )
    combCoefficient_[i] = pow(10.0, (-3.0 * combDelays_[i].getDelay() / (T60 * Stk::sampleRate())));
}

StkFrames& JCRev :: tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() - 1 ) {
    oStream_ << "JCRev::tick(): channel and StkFrames arguments are incompatible!";
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

StkFrames& JCRev :: tick( StkFrames& iFrames, StkFrames& oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() - 1 ) {
    oStream_ << "JCRev::tick(): channel and StkFrames arguments are incompatible!";
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
