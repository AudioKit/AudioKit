/***************************************************/
/*! \class Drummer
    \brief STK drum sample player class.

    This class implements a drum sampling
    synthesizer using FileWvIn objects and one-pole
    filters.  The drum rawwave files are sampled
    at 22050 Hz, but will be appropriately
    interpolated for other sample rates.  You can
    specify the maximum polyphony (maximum number
    of simultaneous voices) via a #define in the
    Drummer.h.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Drummer.h"
#include <cmath>

namespace stk {

// Not really General MIDI yet.
unsigned char genMIDIMap[128] =
  { 0,0,0,0,0,0,0,0,		// 0-7
    0,0,0,0,0,0,0,0,		// 8-15
    0,0,0,0,0,0,0,0,		// 16-23
    0,0,0,0,0,0,0,0,		// 24-31
    0,0,0,0,1,0,2,0,		// 32-39
    2,3,6,3,6,4,7,4,		// 40-47
    5,8,5,0,0,0,10,0,		// 48-55
    9,0,0,0,0,0,0,0,		// 56-63
    0,0,0,0,0,0,0,0,		// 64-71
    0,0,0,0,0,0,0,0,		// 72-79
    0,0,0,0,0,0,0,0,		// 80-87
    0,0,0,0,0,0,0,0,		// 88-95
    0,0,0,0,0,0,0,0,		// 96-103
    0,0,0,0,0,0,0,0,		// 104-111
    0,0,0,0,0,0,0,0,		// 112-119
    0,0,0,0,0,0,0,0     // 120-127
  };
				  
char waveNames[DRUM_NUMWAVES][16] =
  { 
    "dope.raw",
    "bassdrum.raw",
    "snardrum.raw",
    "tomlowdr.raw",
    "tommiddr.raw",
    "tomhidrm.raw",
    "hihatcym.raw",
    "ridecymb.raw",
    "crashcym.raw", 
    "cowbell1.raw", 
    "tambourn.raw"
  };

Drummer :: Drummer( void ) : Instrmnt()
{
  // This counts the number of sounding voices.
  nSounding_ = 0;
  soundOrder_ = std::vector<int> (DRUM_POLYPHONY, -1);
  soundNumber_ = std::vector<int> (DRUM_POLYPHONY, -1);
}

Drummer :: ~Drummer( void )
{
}

void Drummer :: noteOn( StkFloat instrument, StkFloat amplitude )
{
  if ( amplitude < 0.0 || amplitude > 1.0 ) {
    oStream_ << "Drummer::noteOn: amplitude parameter is out of bounds!";
    handleError( StkError::WARNING ); return;
  }

  // Yes, this is tres kludgey.
  int noteNumber = (int) ( ( 12 * log( instrument / 220.0 ) / log( 2.0 ) ) + 57.01 );

  // If we already have a wave of this note number loaded, just reset
  // it.  Otherwise, look first for an unused wave or preempt the
  // oldest if already at maximum polyphony.
  int iWave;
  for ( iWave=0; iWave<DRUM_POLYPHONY; iWave++ ) {
    if ( soundNumber_[iWave] == noteNumber ) {
      if ( waves_[iWave].isFinished() ) {
        soundOrder_[iWave] = nSounding_;
        nSounding_++;
      }
      waves_[iWave].reset();
      filters_[iWave].setPole( 0.999 - (amplitude * 0.6) );
      filters_[iWave].setGain( amplitude );
      break;
    }
  }

  if ( iWave == DRUM_POLYPHONY ) { // This note number is not currently loaded.
    if ( nSounding_ < DRUM_POLYPHONY ) {
      for ( iWave=0; iWave<DRUM_POLYPHONY; iWave++ )
        if ( soundOrder_[iWave] < 0 ) break;
      nSounding_ += 1;
    }
    else { // interrupt oldest voice
      for ( iWave=0; iWave<DRUM_POLYPHONY; iWave++ )
        if ( soundOrder_[iWave] == 0 ) break;
      // Re-order the list.
      for ( int j=0; j<DRUM_POLYPHONY; j++ ) {
        if ( soundOrder_[j] > soundOrder_[iWave] )
          soundOrder_[j] -= 1;
      }
    }
    soundOrder_[iWave] = nSounding_ - 1;
    soundNumber_[iWave] = noteNumber;
    //std::cout << "iWave = " << iWave << ", nSounding = " << nSounding_ << ", soundOrder[] = " << soundOrder_[iWave] << std::endl;

    // Concatenate the STK rawwave path to the rawwave file
    waves_[iWave].openFile( (Stk::rawwavePath() + waveNames[ genMIDIMap[ noteNumber ] ]).c_str(), true );
    if ( Stk::sampleRate() != 22050.0 )
      waves_[iWave].setRate( 22050.0 / Stk::sampleRate() );
    filters_[iWave].setPole( 0.999 - (amplitude * 0.6) );
    filters_[iWave].setGain( amplitude );
  }

  /*
#if defined(_STK_DEBUG_)
  oStream_ << "Drummer::noteOn: number sounding = " << nSounding_ << ", notes: ";
  for ( int i=0; i<nSounding_; i++ ) oStream_ << soundNumber_[i] << "  ";
  oStream_ << '\n';
  handleError( StkError::WARNING );
#endif
  */
}

void Drummer :: noteOff( StkFloat amplitude )
{
  // Set all sounding wave filter gains low.
  int i = 0;
  while ( i < nSounding_ ) filters_[i++].setGain( amplitude * 0.01 );
}

} // stk namespace
