/***************************************************/
/*! \class VoicForm
    \brief Four formant synthesis instrument.

    This instrument contains an excitation singing
    wavetable (looping wave with random and
    periodic vibrato, smoothing on frequency,
    etc.), excitation noise, and four sweepable
    complex resonances.

    Measured formant data is included, and enough
    data is there to support either parallel or
    cascade synthesis.  In the floating point case
    cascade synthesis is the most natural so
    that's what you'll find here.

    Control Change Numbers: 
       - Voiced/Unvoiced Mix = 2
       - Vowel/Phoneme Selection = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Loudness (Spectral Tilt) = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "VoicForm.h"
#include "Phonemes.h"
#include "SKINImsg.h"
#include <cstring>
#include <cmath>

namespace stk {

VoicForm :: VoicForm( void ) : Instrmnt()
{
  // Concatenate the STK rawwave path to the rawwave file
  voiced_ = new SingWave( (Stk::rawwavePath() + "impuls20.raw").c_str(), true );
  voiced_->setGainRate( 0.001 );
  voiced_->setGainTarget( 0.0 );

  for ( int i=0; i<4; i++ )
    filters_[i].setSweepRate( 0.001 );
    
  onezero_.setZero( -0.9 );
  onepole_.setPole( 0.9 );
    
  noiseEnv_.setRate( 0.001 );
  noiseEnv_.setTarget( 0.0 );
    
  this->setPhoneme( "eee" );
  this->clear();
}  

VoicForm :: ~VoicForm( void )
{
  delete voiced_;
}

void VoicForm :: clear( void )
{
  onezero_.clear();
  onepole_.clear();
  for ( int i=0; i<4; i++ ) {
    filters_[i].clear();
  }
}

void VoicForm :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "VoicForm::setFrequency: parameter is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  voiced_->setFrequency( frequency );
}

bool VoicForm :: setPhoneme( const char *phoneme )
{
  bool found = false;
  unsigned int i = 0;
  while( i < 32 && !found ) {
    if ( !strcmp( Phonemes::name(i), phoneme ) ) {
      found = true;
      filters_[0].setTargets( Phonemes::formantFrequency(i, 0), Phonemes::formantRadius(i, 0), pow(10.0, Phonemes::formantGain(i, 0 ) / 20.0) );
      filters_[1].setTargets( Phonemes::formantFrequency(i, 1), Phonemes::formantRadius(i, 1), pow(10.0, Phonemes::formantGain(i, 1 ) / 20.0) );
      filters_[2].setTargets( Phonemes::formantFrequency(i, 2), Phonemes::formantRadius(i, 2), pow(10.0, Phonemes::formantGain(i, 2 ) / 20.0) );
      filters_[3].setTargets( Phonemes::formantFrequency(i, 3), Phonemes::formantRadius(i, 3), pow(10.0, Phonemes::formantGain(i, 3 ) / 20.0) );
      this->setVoiced( Phonemes::voiceGain( i ) );
      this->setUnVoiced( Phonemes::noiseGain( i ) );
    }
    i++;
  }

  if ( !found ) {
    oStream_ << "VoicForm::setPhoneme: phoneme " << phoneme << " not found!";
    handleError( StkError::WARNING );
  }

  return found;
}

void VoicForm :: setFilterSweepRate( unsigned int whichOne, StkFloat rate )
{
  if ( whichOne > 3 ) {
    oStream_ << "VoicForm::setFilterSweepRate: filter select argument outside range 0-3!";
    handleError( StkError::WARNING ); return;
  }

  filters_[whichOne].setSweepRate(rate);
}

void VoicForm :: quiet( void )
{
  voiced_->noteOff();
  noiseEnv_.setTarget( 0.0 );
}

void VoicForm :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  voiced_->setGainTarget( amplitude );
  onepole_.setPole( 0.97 - (amplitude * 0.2) );
}

void VoicForm :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "VoicForm::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_Breath_)	{ // 2
    this->setVoiced( 1.0 - normalizedValue );
    this->setUnVoiced( 0.01 * normalizedValue );
  }
  else if (number == __SK_FootControl_)	{ // 4
    StkFloat temp = 0.0;
    unsigned int i = (int) value;
    if (i < 32)	{
      temp = 0.9;
    }
    else if (i < 64)	{
      i -= 32;
      temp = 1.0;
    }
    else if (i < 96)	{
      i -= 64;
      temp = 1.1;
    }
    else if (i < 128)	{
      i -= 96;
      temp = 1.2;
    }
    else if (i == 128)	{
      i = 0;
      temp = 1.4;
    }
    filters_[0].setTargets( temp * Phonemes::formantFrequency(i, 0), Phonemes::formantRadius(i, 0), pow(10.0, Phonemes::formantGain(i, 0 ) / 20.0) );
    filters_[1].setTargets( temp * Phonemes::formantFrequency(i, 1), Phonemes::formantRadius(i, 1), pow(10.0, Phonemes::formantGain(i, 1 ) / 20.0) );
    filters_[2].setTargets( temp * Phonemes::formantFrequency(i, 2), Phonemes::formantRadius(i, 2), pow(10.0, Phonemes::formantGain(i, 2 ) / 20.0) );
    filters_[3].setTargets( temp * Phonemes::formantFrequency(i, 3), Phonemes::formantRadius(i, 3), pow(10.0, Phonemes::formantGain(i, 3 ) / 20.0) );
    this->setVoiced( Phonemes::voiceGain( i ) );
    this->setUnVoiced( Phonemes::noiseGain( i ) );
  }
  else if (number == __SK_ModFrequency_) // 11
    voiced_->setVibratoRate( normalizedValue * 12.0);  // 0 to 12 Hz
  else if (number == __SK_ModWheel_) // 1
    voiced_->setVibratoGain( normalizedValue * 0.2);
  else if (number == __SK_AfterTouch_Cont_)	{ // 128
    this->setVoiced( normalizedValue );
    onepole_.setPole( 0.97 - ( normalizedValue * 0.2) );
  }
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "VoicForm::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
