/***************************************************/
/*! \class Moog
    \brief STK moog-like swept filter sampling synthesis class.

    This instrument uses one attack wave, one
    looped wave, and an ADSR envelope (inherited
    from the Sampler class) and adds two sweepable
    formant (FormSwep) filters.

    Control Change Numbers: 
       - Filter Q = 2
       - Filter Sweep Rate = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Gain = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Moog.h"
#include "SKINImsg.h"

namespace stk {

Moog :: Moog( void )
{
  // Concatenate the STK rawwave path to the rawwave file
  attacks_.push_back( new FileWvIn( (Stk::rawwavePath() + "mandpluk.raw").c_str(), true ) );
  loops_.push_back ( new FileLoop( (Stk::rawwavePath() + "impuls20.raw").c_str(), true ) );
  loops_.push_back ( new FileLoop( (Stk::rawwavePath() + "sinewave.raw").c_str(), true ) ); // vibrato
  loops_[1]->setFrequency( 6.122 );

  filters_[0].setTargets( 0.0, 0.7 );
  filters_[1].setTargets( 0.0, 0.7 );

  adsr_.setAllTimes( 0.001, 1.5, 0.6, 0.250 );
  filterQ_ = 0.85;
  filterRate_ = 0.0001;
  modDepth_ = 0.0;
}  

Moog :: ~Moog( void )
{
}

void Moog :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Moog::setFrequency: parameter is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  baseFrequency_ = frequency;
  StkFloat rate = attacks_[0]->getSize() * 0.01 * baseFrequency_ / Stk::sampleRate();
  attacks_[0]->setRate( rate );
  loops_[0]->setFrequency( baseFrequency_ );
}

void Moog :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  StkFloat temp;
    
  this->setFrequency( frequency );
  this->keyOn();
  attackGain_ = amplitude * 0.5;
  loopGain_ = amplitude;

  temp = filterQ_ + 0.05;
  filters_[0].setStates( 2000.0, temp );
  filters_[1].setStates( 2000.0, temp );

  temp = filterQ_ + 0.099;
  filters_[0].setTargets( frequency, temp );
  filters_[1].setTargets( frequency, temp );

  filters_[0].setSweepRate( filterRate_ * 22050.0 / Stk::sampleRate() );
  filters_[1].setSweepRate( filterRate_ * 22050.0 / Stk::sampleRate() );
}

void Moog :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Moog::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_FilterQ_) // 2
    filterQ_ = 0.80 + ( 0.1 * normalizedValue );
  else if (number == __SK_FilterSweepRate_) // 4
    filterRate_ = normalizedValue * 0.0002;
  else if (number == __SK_ModFrequency_) // 11
    this->setModulationSpeed( normalizedValue * 12.0 );
  else if (number == __SK_ModWheel_)  // 1
    this->setModulationDepth( normalizedValue );
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Moog::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
