/***************************************************/
/*! \class Modal
    \brief STK resonance model abstract base class.

    This class contains an excitation wavetable,
    an envelope, an oscillator, and N resonances
    (non-sweeping BiQuad filters), where N is set
    during instantiation.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Modal.h"
#include <cstdlib>

namespace stk {

Modal :: Modal( unsigned int modes )
  : nModes_(modes)
{
  if ( nModes_ == 0 ) {
    oStream_ << "Modal: 'modes' argument to constructor is zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  // We don't make the excitation wave here yet, because we don't know
  // what it's going to be.

  ratios_.resize( nModes_ );
  radii_.resize( nModes_ );
  filters_ = (BiQuad **) calloc( nModes_, sizeof(BiQuad *) );
  for (unsigned int i=0; i<nModes_; i++ ) {
    filters_[i] = new BiQuad;
    filters_[i]->setEqualGainZeroes();
  }

  // Set some default values.
  vibrato_.setFrequency( 6.0 );
  vibratoGain_ = 0.0;
  directGain_ = 0.0;
  masterGain_ = 1.0;
  baseFrequency_ = 440.0;

  this->clear();

  stickHardness_ =  0.5;
  strikePosition_ = 0.561;
}  

Modal :: ~Modal( void )
{
  for ( unsigned int i=0; i<nModes_; i++ ) {
    delete filters_[i];
  }
  free( filters_ );
}

void Modal :: clear( void )
{    
  onepole_.clear();
  for ( unsigned int i=0; i<nModes_; i++ )
    filters_[i]->clear();
}

void Modal :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Modal::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  baseFrequency_ = frequency;
  for ( unsigned int i=0; i<nModes_; i++ )
    this->setRatioAndRadius( i, ratios_[i], radii_[i] );
}

void Modal :: setRatioAndRadius( unsigned int modeIndex, StkFloat ratio, StkFloat radius )
{
  if ( modeIndex >= nModes_ ) {
    oStream_ << "Modal::setRatioAndRadius: modeIndex parameter is greater than number of modes!";
    handleError( StkError::WARNING ); return;
  }

  StkFloat nyquist = Stk::sampleRate() / 2.0;
  StkFloat temp;

  if ( ratio * baseFrequency_ < nyquist ) {
    ratios_[modeIndex] = ratio;
  }
  else {
    temp = ratio;
    while (temp * baseFrequency_ > nyquist) temp *= 0.5;
    ratios_[modeIndex] = temp;
#if defined(_STK_DEBUG_)
    oStream_ << "Modal::setRatioAndRadius: aliasing would occur here ... correcting.";
    handleError( StkError::DEBUG_PRINT );
#endif
  }
  radii_[modeIndex] = radius;
  if (ratio < 0) 
    temp = -ratio;
  else
    temp = ratio * baseFrequency_;

  filters_[modeIndex]->setResonance(temp, radius);
}

void Modal :: setModeGain( unsigned int modeIndex, StkFloat gain )
{
  if ( modeIndex >= nModes_ ) {
    oStream_ << "Modal::setModeGain: modeIndex parameter is greater than number of modes!";
    handleError( StkError::WARNING ); return;
  }

  filters_[modeIndex]->setGain( gain );
}

void Modal :: strike( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Modal::strike: amplitude is out of range!";
    handleError( StkError::WARNING );
  }

  envelope_.setRate( 1.0 );
  envelope_.setTarget( amplitude );
  onepole_.setPole( 1.0 - amplitude );
  envelope_.tick();
  wave_->reset();

  StkFloat temp;
  for ( unsigned int i=0; i<nModes_; i++ ) {
    if (ratios_[i] < 0)
      temp = -ratios_[i];
    else
      temp = ratios_[i] * baseFrequency_;
    filters_[i]->setResonance(temp, radii_[i]);
  }
}

void Modal :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->strike( amplitude );
  this->setFrequency( frequency );
}

void Modal :: noteOff( StkFloat amplitude )
{
  // This calls damp, but inverts the meaning of amplitude (high
  // amplitude means fast damping).
  this->damp( 1.0 - (amplitude * 0.03) );
}

void Modal :: damp( StkFloat amplitude )
{
  StkFloat temp;
  for ( unsigned int i=0; i<nModes_; i++ ) {
    if ( ratios_[i] < 0 )
      temp = -ratios_[i];
    else
      temp = ratios_[i] * baseFrequency_;
    filters_[i]->setResonance( temp, radii_[i]*amplitude );
  }
}

} // stk namespace
