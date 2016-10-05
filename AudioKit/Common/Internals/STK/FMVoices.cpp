/***************************************************/
/*! \class FMVoices
    \brief STK singing FM synthesis instrument.

    This class implements 3 carriers and a common
    modulator, also referred to as algorithm 6 of
    the TX81Z.

    \code
    Algorithm 6 is :
                        /->1 -\
                     4-|-->2 - +-> Out
                        \->3 -/
    \endcode

    Control Change Numbers: 
       - Vowel = 2
       - Spectral Tilt = 4
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

#include "FMVoices.h"
#include "SKINImsg.h"
#include "Phonemes.h"

namespace stk {

FMVoices :: FMVoices( void )
  : FM()
{
  // Concatenate the STK rawwave path to the rawwave files
  for ( unsigned int i=0; i<3; i++ )
    waves_[i] = new FileLoop( (Stk::rawwavePath() + "sinewave.raw").c_str(), true );
  waves_[3] = new FileLoop( (Stk::rawwavePath() + "fwavblnk.raw").c_str(), true );

  this->setRatio(0, 2.00);
  this->setRatio(1, 4.00);
  this->setRatio(2, 12.0);
  this->setRatio(3, 1.00);

  gains_[3] = fmGains_[80];

  adsr_[0]->setAllTimes( 0.05, 0.05, fmSusLevels_[15], 0.05);
  adsr_[1]->setAllTimes( 0.05, 0.05, fmSusLevels_[15], 0.05);
  adsr_[2]->setAllTimes( 0.05, 0.05, fmSusLevels_[15], 0.05);
  adsr_[3]->setAllTimes( 0.01, 0.01, fmSusLevels_[15], 0.5);

  twozero_.setGain( 0.0 );
  modDepth_ = (StkFloat) 0.005;
  currentVowel_ = 0;
  tilt_[0] = 1.0;
  tilt_[1] = 0.5;
  tilt_[2] = 0.2;    
  mods_[0] = 1.0;
  mods_[1] = 1.1;
  mods_[2] = 1.1;
  baseFrequency_ = 110.0;
  this->setFrequency( 110.0 );    
}  

FMVoices :: ~FMVoices( void )
{
}

void FMVoices :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "FMVoices::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat temp, temp2 = 0.0;
  int tempi = 0;
  unsigned int i = 0;

  if (currentVowel_ < 32)	{
    i = currentVowel_;
    temp2 = 0.9;
  }
  else if (currentVowel_ < 64)	{
    i = currentVowel_ - 32;
    temp2 = 1.0;
  }
  else if (currentVowel_ < 96)	{
    i = currentVowel_ - 64;
    temp2 = 1.1;
  }
  else if (currentVowel_ <= 128)	{
    i = currentVowel_ - 96;
    temp2 = 1.2;
  }

  baseFrequency_ = frequency;
  temp = (temp2 * Phonemes::formantFrequency(i, 0) / baseFrequency_) + 0.5;
  tempi = (int) temp;
  this->setRatio( 0, (StkFloat) tempi );
  temp = (temp2 * Phonemes::formantFrequency(i, 1) / baseFrequency_) + 0.5;
  tempi = (int) temp;
  this->setRatio( 1, (StkFloat) tempi );
  temp = (temp2 * Phonemes::formantFrequency(i, 2) / baseFrequency_) + 0.5;
  tempi = (int) temp;
  this->setRatio( 2, (StkFloat) tempi );    
  gains_[0] = 1.0;
  gains_[1] = 1.0;
  gains_[2] = 1.0;
}

void FMVoices :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  tilt_[0] = amplitude;
  tilt_[1] = amplitude * amplitude;
  tilt_[2] = tilt_[1] * amplitude;
  this->keyOn();
}

void FMVoices :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "FMVoices::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_Breath_) // 2
    gains_[3] = fmGains_[(int) ( normalizedValue * 99.9 )];
  else if (number == __SK_FootControl_)	{ // 4
    currentVowel_ = (int) (normalizedValue * 128.0);
    this->setFrequency(baseFrequency_);
  }
  else if (number == __SK_ModFrequency_) // 11
    this->setModulationSpeed( normalizedValue * 12.0);
  else if (number == __SK_ModWheel_) // 1
    this->setModulationDepth( normalizedValue );
  else if (number == __SK_AfterTouch_Cont_)	{ // 128
    tilt_[0] = normalizedValue;
    tilt_[1] = normalizedValue * normalizedValue;
    tilt_[2] = tilt_[1] * normalizedValue;
  }
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "FMVoices::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
