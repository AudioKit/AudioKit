/***********************************************************************/
/*! \class FreeVerb
    \brief Jezar at Dreampoint's FreeVerb, implemented in STK.

    Freeverb is a free and open-source Schroeder reverberator
    originally implemented in C++. The parameters of the reverberation
    model are exceptionally well tuned. FreeVerb uses 8
    lowpass-feedback-comb-filters in parallel, followed by 4 Schroeder
    allpass filters in series.  The input signal can be either mono or
    stereo, and the output signal is stereo.  The delay lengths are
    optimized for a sample rate of 44100 Hz.

    Ported to STK by Gregory Burlet, 2012.
*/
/***********************************************************************/

#include "FreeVerb.h"
#include <cmath>
#include <iostream>

using namespace stk;

// Set static delay line lengths
const StkFloat FreeVerb::fixedGain = 0.015;
const StkFloat FreeVerb::scaleWet = 3;
const StkFloat FreeVerb::scaleDry = 2;
const StkFloat FreeVerb::scaleDamp = 0.4;
const StkFloat FreeVerb::scaleRoom = 0.28;
const StkFloat FreeVerb::offsetRoom = 0.7;
int FreeVerb::cDelayLengths[] = {1617, 1557, 1491, 1422, 1356, 1277, 1188, 1116};
int FreeVerb::aDelayLengths[] = {225, 556, 441, 341};

FreeVerb::FreeVerb( void )
{
  // Resize lastFrame_ for stereo output
  lastFrame_.resize( 1, 2, 0.0 );

  // Initialize parameters
  Effect::setEffectMix( 0.75 ); // set initially to 3/4 wet 1/4 dry signal (different than original freeverb) 
  roomSizeMem_ = (0.75 * scaleRoom) + offsetRoom; // feedback attenuation in LBFC
  dampMem_ = 0.25 * scaleDamp;                    // pole of lowpass filters in the LBFC
  width_ = 1.0;
  frozenMode_ = false;
  update();

  gain_ = fixedGain;      // input gain before sending to filters
  g_ = 0.5;               // allpass coefficient, immutable in FreeVerb

  // Scale delay line lengths according to the current sampling rate
  double fsScale = Stk::sampleRate() / 44100.0;
  if ( fsScale != 1.0 ) {
    // scale comb filter delay lines
    for ( int i = 0; i < nCombs; i++ ) {
      cDelayLengths[i] = (int) floor(fsScale * cDelayLengths[i]);
    }

    // Scale allpass filter delay lines
    for ( int i = 0; i < nAllpasses; i++ ) {
      aDelayLengths[i] = (int) floor(fsScale * aDelayLengths[i]);
    }
  }

  // Initialize delay lines for the LBFC filters
  for ( int i = 0; i < nCombs; i++ ) {
    combDelayL_[i].setMaximumDelay( cDelayLengths[i] );
    combDelayL_[i].setDelay( cDelayLengths[i] );
    combDelayR_[i].setMaximumDelay( cDelayLengths[i] + stereoSpread );
    combDelayR_[i].setDelay( cDelayLengths[i] + stereoSpread );
  }

  // initialize delay lines for the allpass filters
  for (int i = 0; i < nAllpasses; i++) {
    allPassDelayL_[i].setMaximumDelay( aDelayLengths[i] );
    allPassDelayL_[i].setDelay( aDelayLengths[i] );
    allPassDelayR_[i].setMaximumDelay( aDelayLengths[i] + stereoSpread );
    allPassDelayR_[i].setDelay( aDelayLengths[i] + stereoSpread );
  }
}

FreeVerb::~FreeVerb()
{
}

void FreeVerb::setEffectMix( StkFloat mix )
{
  Effect::setEffectMix( mix );
  update();    
}

void FreeVerb::setRoomSize( StkFloat roomSize )
{
  roomSizeMem_ = (roomSize * scaleRoom) + offsetRoom;
  update();
}

StkFloat FreeVerb::getRoomSize()
{
  return (roomSizeMem_ - offsetRoom) / scaleRoom;
}

void FreeVerb::setDamping( StkFloat damping )
{
  dampMem_ = damping * scaleDamp;
  update();
}

StkFloat FreeVerb::getDamping()
{
  return dampMem_ / scaleDamp;
}

void FreeVerb::setWidth( StkFloat width )
{
  width_ = width;
  update();
}

StkFloat FreeVerb::getWidth()
{
  return width_;
}

void FreeVerb::setMode( bool isFrozen )
{
  frozenMode_ = isFrozen;
  update();
}

StkFloat FreeVerb::getMode()
{
  return frozenMode_;
}

void FreeVerb::update()
{
  StkFloat wet = scaleWet * effectMix_;
  dry_ = scaleDry * (1.0-effectMix_);

  // Use the L1 norm so the output gain will sum to one while still
  // preserving the ratio of scalings in original FreeVerb
  wet /= (wet + dry_);
  dry_ /= (wet + dry_);

  wet1_ = wet * (width_/2.0 + 0.5);
  wet2_ = wet * (1.0 - width_)/2.0;

  if ( frozenMode_ ) {
    // put into freeze mode
    roomSize_ = 1.0;
    damp_ = 0.0;
    gain_ = 0.0;
  }
  else {
    roomSize_ = roomSizeMem_;
    damp_ = dampMem_;
    gain_ = fixedGain;
  }

  for ( int i=0; i<nCombs; i++ ) {
    // set low pass filter for delay output
    combLPL_[i].setCoefficients(1.0 - damp_, -damp_);
    combLPR_[i].setCoefficients(1.0 - damp_, -damp_);
  }
}

void FreeVerb::clear()
{
  // Clear LBFC delay lines
  for ( int i = 0; i < nCombs; i++ ) {
    combDelayL_[i].clear();
    combDelayR_[i].clear();
  }

  // Clear allpass delay lines
  for ( int i = 0; i < nAllpasses; i++ ) {
    allPassDelayL_[i].clear();
    allPassDelayR_[i].clear();
  }

  lastFrame_[0] = 0.0;
  lastFrame_[1] = 0.0;
}

StkFrames& FreeVerb::tick( StkFrames& frames, unsigned int channel )
{
#if defined(_STK_DEBUG_)
  if ( channel >= frames.channels() - 1 ) {
    oStream_ << "FreeVerb::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int hop = frames.channels();
  for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
    *samples = tick( *samples, *(samples+1) );
    *(samples+1) = lastFrame_[1];
  }

  return frames;
}

StkFrames& FreeVerb::tick( StkFrames& iFrames, StkFrames &oFrames, unsigned int iChannel, unsigned int oChannel )
{
#if defined(_STK_DEBUG_)
  if ( iChannel >= iFrames.channels() || oChannel >= oFrames.channels() - 1 ) {
    oStream_ << "FreeVerb::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *iSamples = &iFrames[iChannel];
  StkFloat *oSamples = &oFrames[oChannel];
  unsigned int iHop = iFrames.channels();
  unsigned int oHop = oFrames.channels();
  bool stereoInput = ( iFrames.channels() > iChannel+1 ) ? true : false;
  for ( unsigned int i=0; i<iFrames.frames(); i++, iSamples += iHop, oSamples += oHop) {
    if ( stereoInput )
      *oSamples = tick( *iSamples, *(iSamples+1) );
    else
      *oSamples = tick( *iSamples );

    *(oSamples+1) = lastFrame_[1];
  }

  return oFrames;
}
