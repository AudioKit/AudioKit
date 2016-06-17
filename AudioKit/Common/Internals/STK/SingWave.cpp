/***************************************************/
/*! \class SingWave
    \brief STK "singing" looped soundfile class.

    This class loops a specified soundfile and modulates it both
    periodically and randomly to produce a pitched musical sound, like
    a simple voice or violin.  In general, it is not be used alone
    because of "munchkinification" effects from pitch shifting.
    Within STK, it is used as an excitation source for other
    instruments.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "SingWave.h"

namespace stk {
 
SingWave :: SingWave( std::string fileName, bool raw )
{
  // An exception could be thrown here.
  wave_.openFile( fileName, raw );

	rate_ = 1.0;
	sweepRate_ = 0.001;

	modulator_.setVibratoRate( 6.0 );
	modulator_.setVibratoGain( 0.04 );
	modulator_.setRandomGain( 0.005 );

	this->setFrequency( 75.0 );
	pitchEnvelope_.setRate( 1.0 );
	this->tick();
	this->tick();
	pitchEnvelope_.setRate( sweepRate_ * rate_ );
}

SingWave :: ~SingWave()
{
}

void SingWave :: setFrequency( StkFloat frequency )
{
	StkFloat temp = rate_;
	rate_ = wave_.getSize() * frequency / Stk::sampleRate();
	temp -= rate_;
	if ( temp < 0) temp = -temp;
	pitchEnvelope_.setTarget( rate_ );
	pitchEnvelope_.setRate( sweepRate_ * temp );
}

} // stk namespace
