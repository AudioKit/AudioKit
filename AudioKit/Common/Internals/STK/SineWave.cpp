/***************************************************/
/*! \class SineWave
    \brief STK sinusoid oscillator class.

    This class computes and saves a static sine "table" that can be
    shared by multiple instances.  It has an interface similar to the
    WaveLoop class but inherits from the Generator class.  Output
    values are computed using linear interpolation.

    The "table" length, set in SineWave.h, is 2048 samples by default.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "SineWave.h"
#include <cmath>

namespace stk {

StkFrames SineWave :: table_;

SineWave :: SineWave( void )
  : time_(0.0), rate_(1.0), phaseOffset_(0.0)
{
  if ( table_.empty() ) {
    table_.resize( TABLE_SIZE + 1, 1 );
    StkFloat temp = 1.0 / TABLE_SIZE;
    for ( unsigned long i=0; i<=TABLE_SIZE; i++ )
      table_[i] = sin( TWO_PI * i * temp );
  }

  Stk::addSampleRateAlert( this );
}

SineWave :: ~SineWave()
{
  Stk::removeSampleRateAlert( this );
}

void SineWave :: sampleRateChanged( StkFloat newRate, StkFloat oldRate )
{
  if ( !ignoreSampleRateChange_ )
    this->setRate( oldRate * rate_ / newRate );
}

void SineWave :: reset( void )
{
  time_ = 0.0;
  lastFrame_[0] = 0;
}

void SineWave :: setFrequency( StkFloat frequency )
{
  // This is a looping frequency.
  this->setRate( TABLE_SIZE * frequency / Stk::sampleRate() );
}

void SineWave :: addTime( StkFloat time )
{
  // Add an absolute time in samples.
  time_ += time;
}

void SineWave :: addPhase( StkFloat phase )
{
  // Add a time in cycles (one cycle = TABLE_SIZE).
  time_ += TABLE_SIZE * phase;
}

void SineWave :: addPhaseOffset( StkFloat phaseOffset )
{
  // Add a phase offset relative to any previous offset value.
  time_ += ( phaseOffset - phaseOffset_ ) * TABLE_SIZE;
  phaseOffset_ = phaseOffset;
}

} // stk namespace
