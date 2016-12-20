/***************************************************/
/*! \class Mandolin
    \brief STK mandolin instrument model class.

    This class uses two "twang" models and "commuted
    synthesis" techniques to model a mandolin
    instrument.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.  Commuted
    Synthesis, in particular, is covered by patents,
    granted, pending, and/or applied-for.  All are
    assigned to the Board of Trustees, Stanford
    University.  For information, contact the Office
    of Technology Licensing, Stanford University.

    Control Change Numbers: 
       - Body Size = 2
       - Pluck Position = 4
       - String Sustain = 11
       - String Detuning = 1
       - Microphone Position = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Mandolin.h"
#include "SKINImsg.h"

namespace stk {

Mandolin :: Mandolin( StkFloat lowestFrequency )
{
  if ( lowestFrequency <= 0.0 ) {
    oStream_ << "Mandolin::Mandolin: argument is less than or equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  // Concatenate the STK rawwave path to the rawwave files
  soundfile_[0].openFile( (Stk::rawwavePath() + "mand1.raw").c_str(), true );
  soundfile_[1].openFile( (Stk::rawwavePath() + "mand2.raw").c_str(), true );
  soundfile_[2].openFile( (Stk::rawwavePath() + "mand3.raw").c_str(), true );
  soundfile_[3].openFile( (Stk::rawwavePath() + "mand4.raw").c_str(), true );
  soundfile_[4].openFile( (Stk::rawwavePath() + "mand5.raw").c_str(), true );
  soundfile_[5].openFile( (Stk::rawwavePath() + "mand6.raw").c_str(), true );
  soundfile_[6].openFile( (Stk::rawwavePath() + "mand7.raw").c_str(), true );
  soundfile_[7].openFile( (Stk::rawwavePath() + "mand8.raw").c_str(), true );
  soundfile_[8].openFile( (Stk::rawwavePath() + "mand9.raw").c_str(), true );
  soundfile_[9].openFile( (Stk::rawwavePath() + "mand10.raw").c_str(), true );
  soundfile_[10].openFile( (Stk::rawwavePath() + "mand11.raw").c_str(), true );
  soundfile_[11].openFile( (Stk::rawwavePath() + "mand12.raw").c_str(), true );

  mic_ = 0;
  detuning_ = 0.995;
  pluckAmplitude_ = 0.5;

  strings_[0].setLowestFrequency( lowestFrequency );
  strings_[1].setLowestFrequency( lowestFrequency );
  this->setFrequency( 220.0 );
  this->setPluckPosition( 0.4 );
}

Mandolin :: ~Mandolin( void )
{
}

void Mandolin :: clear( void )
{
  strings_[0].clear();
  strings_[1].clear();
}

void Mandolin :: setPluckPosition( StkFloat position )
{
  if ( position < 0.0 || position > 1.0 ) {
    std::cerr << "Mandolin::setPluckPosition: position parameter out of range!";
    handleError( StkError::WARNING ); return;
  }

  strings_[0].setPluckPosition( position );
  strings_[1].setPluckPosition( position );
}

void Mandolin :: setDetune( StkFloat detune )
{
  if ( detune <= 0.0 ) {
    oStream_ << "Mandolin::setDetune: parameter is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  detuning_ = detune;
  strings_[1].setFrequency( frequency_ * detuning_ );
}

void Mandolin :: setBodySize( StkFloat size )
{
  // Scale the commuted body response by its sample rate (22050).
  StkFloat rate = size * 22050.0 / Stk::sampleRate();
  for ( int i=0; i<12; i++ )
    soundfile_[i].setRate( rate );
}

void Mandolin :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "Mandolin::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  frequency_ = frequency;
  strings_[0].setFrequency( frequency_ );
  strings_[1].setFrequency( frequency_ * detuning_ );
}

void Mandolin :: pluck( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Mandolin::pluck: amplitude parameter out of range!";
    handleError( StkError::WARNING ); return;
  }

  soundfile_[mic_].reset();
  pluckAmplitude_ = amplitude;

  //strings_[0].setLoopGain( 0.97 + pluckAmplitude_ * 0.03 );
  //strings_[1].setLoopGain( 0.97 + pluckAmplitude_ * 0.03 );
}

void Mandolin :: pluck( StkFloat amplitude, StkFloat position )
{
  this->setPluckPosition( position );
  this->pluck( amplitude );
}

void Mandolin :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  this->pluck( amplitude );
}

void Mandolin :: noteOff( StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Mandolin::noteOff: amplitude is out of range!";
    handleError( StkError::WARNING ); return;
  }

  //strings_[0].setLoopGain( 0.97 + (1 - amplitude) * 0.03 );
  //strings_[1].setLoopGain( 0.97 + (1 - amplitude) * 0.03 );
}

void Mandolin :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Mandolin::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if ( number == __SK_BodySize_ ) // 2
    this->setBodySize( normalizedValue * 2.0 );
  else if ( number == __SK_PickPosition_ ) // 4
    this->setPluckPosition( normalizedValue );
  else if ( number == __SK_StringDamping_ ) { // 11
    strings_[0].setLoopGain( 0.97 + (normalizedValue * 0.03) );
    strings_[1].setLoopGain( 0.97 + (normalizedValue * 0.03) );
  }
  else if ( number == __SK_StringDetune_ ) // 1
    this->setDetune( 1.0 - (normalizedValue * 0.1) );
  else if ( number == __SK_AfterTouch_Cont_ ) // 128
    mic_ = (int) (normalizedValue * 11.0);
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Mandolin::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
