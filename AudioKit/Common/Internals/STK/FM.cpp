/***************************************************/
/*! \class FM
    \brief STK abstract FM synthesis base class.

    This class controls an arbitrary number of
    waves and envelopes, determined via a
    constructor argument.

    Control Change Numbers: 
       - Control One = 2
       - Control Two = 4
       - LFO Speed = 11
       - LFO Depth = 1
       - ADSR 2 & 4 Target = 128

    The basic Chowning/Stanford FM patent expired
    in 1995, but there exist follow-on patents,
    mostly assigned to Yamaha.  If you are of the
    type who should worry about this (making
    money) worry away.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "FM.h"
#include "SKINImsg.h"

namespace stk {

FM :: FM( unsigned int operators )
  : nOperators_(operators)
{
  if ( nOperators_ == 0 ) {
    oStream_ << "FM::FM: Number of operators must be greater than zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  twozero_.setB2( -1.0 );
  twozero_.setGain( 0.0 );

  vibrato_.setFrequency( 6.0 );

  unsigned int j;
  adsr_.resize( nOperators_ );
  waves_.resize( nOperators_ );
  for (j=0; j<nOperators_; j++ ) {
    ratios_.push_back( 1.0 );
    gains_.push_back( 1.0 );
    adsr_[j] = new ADSR();
  }

  modDepth_ = 0.0;
  control1_ = 1.0;
  control2_ = 1.0;
  baseFrequency_ = 440.0;

  int i;
  StkFloat temp = 1.0;
  for (i=99; i>=0; i--) {
    fmGains_[i] = temp;
    temp *= 0.933033;
  }

  temp = 1.0;
  for (i=15; i>=0; i--) {
    fmSusLevels_[i] = temp;
    temp *= 0.707101;
  }

  temp = 8.498186;
  for (i=0; i<32; i++) {
    fmAttTimes_[i] = temp;
    temp *= 0.707101;
  }
}

FM :: ~FM( void )
{
  for (unsigned int i=0; i<nOperators_; i++ ) {
    delete waves_[i];
    delete adsr_[i];
  }
}

void FM :: loadWaves( const char **filenames )
{
  for (unsigned int i=0; i<nOperators_; i++ )
    waves_[i] = new FileLoop( filenames[i], true );
}

void FM :: setFrequency( StkFloat frequency )
{    
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "FM::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  baseFrequency_ = frequency;
  for ( unsigned int i=0; i<nOperators_; i++ )
    waves_[i]->setFrequency( baseFrequency_ * ratios_[i] );
}

void FM :: setRatio( unsigned int waveIndex, StkFloat ratio )
{
  if ( waveIndex >= nOperators_ ) {
    oStream_ << "FM:setRatio: waveIndex parameter is greater than the number of operators!";
    handleError( StkError::WARNING ); return;
  }

  ratios_[waveIndex] = ratio;
  if (ratio > 0.0) 
    waves_[waveIndex]->setFrequency( baseFrequency_ * ratio );
  else
    waves_[waveIndex]->setFrequency( ratio );
}

void FM :: setGain( unsigned int waveIndex, StkFloat gain )
{
  if ( waveIndex >= nOperators_ ) {
    oStream_ << "FM::setGain: waveIndex parameter is greater than the number of operators!";
    handleError( StkError::WARNING ); return;
  }

  gains_[waveIndex] = gain;
}

void FM :: keyOn( void )
{
  for ( unsigned int i=0; i<nOperators_; i++ )
    adsr_[i]->keyOn();
}

void FM :: keyOff( void )
{
  for ( unsigned int i=0; i<nOperators_; i++ )
    adsr_[i]->keyOff();
}

void FM :: noteOff( StkFloat amplitude )
{
  this->keyOff();
}

void FM :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "FM::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_Breath_) // 2
    this->setControl1( normalizedValue );
  else if (number == __SK_FootControl_) // 4
    this->setControl2( normalizedValue );
  else if (number == __SK_ModFrequency_) // 11
    this->setModulationSpeed( normalizedValue * 12.0);
  else if (number == __SK_ModWheel_) // 1
    this->setModulationDepth( normalizedValue );
  else if (number == __SK_AfterTouch_Cont_)	{ // 128
    //adsr_[0]->setTarget( normalizedValue );
    adsr_[1]->setTarget( normalizedValue );
    //adsr_[2]->setTarget( normalizedValue );
    adsr_[3]->setTarget( normalizedValue );
  }
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "FM::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
