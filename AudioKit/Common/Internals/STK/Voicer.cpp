/***************************************************/
/*! \class Voicer
    \brief STK voice manager class.

    This class can be used to manage a group of STK instrument
    classes.  Individual voices can be controlled via unique note
    tags.  Instrument groups can be controlled by group number.

    A previously constructed STK instrument class is linked with a
    voice manager using the addInstrument() function.  An optional
    group number argument can be specified to the addInstrument()
    function as well (default group = 0).  The voice manager does not
    delete any instrument instances ... it is the responsibility of
    the user to allocate and deallocate all instruments.

    The tick() function returns the mix of all sounding voices.  Each
    noteOn returns a unique tag (credits to the NeXT MusicKit), so you
    can send control changes to specific voices within an ensemble.
    Alternately, control changes can be sent to all voices in a given
    group.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Voicer.h"
#include <cmath>

namespace stk {

Voicer :: Voicer( StkFloat decayTime )
{
  if ( decayTime < 0.0 ) {
    oStream_ << "Voicer::Voicer: argument (" << decayTime << ") must be positive!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  tags_ = 23456;
  muteTime_ = (int) ( decayTime * Stk::sampleRate() );
  lastFrame_.resize( 1, 1, 0.0 );
}

void Voicer :: addInstrument( Instrmnt *instrument, int group )
{
  Voicer::Voice voice;
  voice.instrument = instrument;
  voice.group = group;
  voice.noteNumber = -1;
  voices_.push_back( voice );

  // Check output channels and resize lastFrame_ if necessary.
  if ( instrument->channelsOut() > lastFrame_.channels() ) {
    unsigned int startChannel = lastFrame_.channels();
    lastFrame_.resize( 1, instrument->channelsOut() );
    for ( unsigned int i=startChannel; i<lastFrame_.size(); i++ )
      lastFrame_[i] = 0.0;
  }
}

void Voicer :: removeInstrument( Instrmnt *instrument )
{
  bool found = false;
  std::vector< Voicer::Voice >::iterator i;
  for ( i=voices_.begin(); i!=voices_.end(); ++i ) {
    if ( (*i).instrument != instrument ) continue;
    voices_.erase( i );
    found = true;
    break;
  }

  if ( found ) {
    // Check output channels and resize lastFrame_ if necessary.
    unsigned int maxChannels = 1;
    for ( i=voices_.begin(); i!=voices_.end(); ++i ) {
      if ( (*i).instrument->channelsOut() > maxChannels ) maxChannels = (*i).instrument->channelsOut();
    }
    if ( maxChannels < lastFrame_.channels() )
      lastFrame_.resize( 1, maxChannels );
  }
  else {
    oStream_ << "Voicer::removeInstrument: instrument pointer not found in current voices!";
    handleError( StkError::WARNING );
  }
}

long Voicer :: noteOn(StkFloat noteNumber, StkFloat amplitude, int group )
{
  unsigned int i;
  StkFloat frequency = (StkFloat) 220.0 * pow( 2.0, (noteNumber - 57.0) / 12.0 );
  for ( i=0; i<voices_.size(); i++ ) {
    if (voices_[i].noteNumber < 0 && voices_[i].group == group) {
      voices_[i].tag = tags_++;
      voices_[i].group = group;
      voices_[i].noteNumber = noteNumber;
      voices_[i].frequency = frequency;
      voices_[i].instrument->noteOn( frequency, amplitude * ONE_OVER_128 );
      voices_[i].sounding = 1;
      return voices_[i].tag;
    }
  }

  // All voices are sounding, so interrupt the oldest voice.
  int voice = -1;
  for ( i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].group == group ) {
      if ( voice == -1 ) voice = i;
      else if ( voices_[i].tag < voices_[voice].tag ) voice = (int) i;
    }
  }

  if ( voice >= 0 ) {
    voices_[voice].tag = tags_++;
    voices_[voice].group = group;
    voices_[voice].noteNumber = noteNumber;
    voices_[voice].frequency = frequency;
    voices_[voice].instrument->noteOn( frequency, amplitude * ONE_OVER_128 );
    voices_[voice].sounding = 1;
    return voices_[voice].tag;
  }

  return -1;
}

void Voicer :: noteOff( StkFloat noteNumber, StkFloat amplitude, int group )
{
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].noteNumber == noteNumber && voices_[i].group == group ) {
      voices_[i].instrument->noteOff( amplitude * ONE_OVER_128 );
      voices_[i].sounding = -muteTime_;
    }
  }
}

void Voicer :: noteOff( long tag, StkFloat amplitude )
{
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].tag == tag ) {
      voices_[i].instrument->noteOff( amplitude * ONE_OVER_128 );
      voices_[i].sounding = -muteTime_;
      break;
    }
  }
}

void Voicer :: setFrequency( StkFloat noteNumber, int group )
{
  StkFloat frequency = (StkFloat) 220.0 * pow( 2.0, (noteNumber - 57.0) / 12.0 );
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].group == group ) {
      voices_[i].noteNumber = noteNumber;
      voices_[i].frequency = frequency;
      voices_[i].instrument->setFrequency( frequency );
    }
  }
}

void Voicer :: setFrequency( long tag, StkFloat noteNumber )
{
  StkFloat frequency = (StkFloat) 220.0 * pow( 2.0, (noteNumber - 57.0) / 12.0 );
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].tag == tag ) {
      voices_[i].noteNumber = noteNumber;
      voices_[i].frequency = frequency;
      voices_[i].instrument->setFrequency( frequency );
      break;
    }
  }
}

void Voicer :: pitchBend( StkFloat value, int group )
{
  StkFloat pitchScaler;
  if ( value < 8192.0 )
    pitchScaler = pow( 0.5, (8192.0-value) / 8192.0 );
  else
    pitchScaler = pow( 2.0, (value-8192.0) / 8192.0 );
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].group == group )
      voices_[i].instrument->setFrequency( (StkFloat) (voices_[i].frequency * pitchScaler) );
  }
}

void Voicer :: pitchBend( long tag, StkFloat value )
{
  StkFloat pitchScaler;
  if ( value < 8192.0 )
    pitchScaler = pow( 0.5, (8192.0-value) / 8192.0 );
  else
    pitchScaler = pow( 2.0, (value-8192.0) / 8192.0 );
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].tag == tag ) {
      voices_[i].instrument->setFrequency( (StkFloat) (voices_[i].frequency * pitchScaler) );
      break;
    }
  }
}

void Voicer :: controlChange( int number, StkFloat value, int group )
{
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].group == group )
      voices_[i].instrument->controlChange( number, value );
  }
}

void Voicer :: controlChange( long tag, int number, StkFloat value )
{
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].tag == tag ) {
      voices_[i].instrument->controlChange( number, value );
      break;
    }
  }
}

void Voicer :: silence( void )
{
  for ( unsigned int i=0; i<voices_.size(); i++ ) {
    if ( voices_[i].sounding > 0 )
      voices_[i].instrument->noteOff( 0.5 );
  }
}

} // stk namespace
