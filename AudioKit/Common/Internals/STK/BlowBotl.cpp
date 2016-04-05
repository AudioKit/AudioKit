/***************************************************/
/*! \class BlowBotl
    \brief STK blown bottle instrument class.

    This class implements a helmholtz resonator
    (biquad filter) with a polynomial jet
    excitation (a la Cook).

    Control Change Numbers: 
       - Noise Gain = 4
       - Vibrato Frequency = 11
       - Vibrato Gain = 1
       - Volume = 128

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "BlowBotl.h"
#include "SKINImsg.h"

namespace stk {

#define __BOTTLE_RADIUS_ 0.999

BlowBotl :: BlowBotl( void )
{
  dcBlock_.setBlockZero();

  vibrato_.setFrequency( 5.925 );
  vibratoGain_ = 0.0;

  resonator_.setResonance( 500.0, __BOTTLE_RADIUS_, true );
  adsr_.setAllTimes( 0.005, 0.01, 0.8, 0.010 );

  noiseGain_ = 20.0;
	maxPressure_ = 0.0;
}

BlowBotl :: ~BlowBotl( void )
{
}

void BlowBotl :: clear( void )
{
  resonator_.clear();
}

void BlowBotl :: setFrequency( StkFloat frequency )
{
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "BlowBotl::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  resonator_.setResonance( frequency, __BOTTLE_RADIUS_, true );
}

void BlowBotl :: startBlowing( StkFloat amplitude, StkFloat rate )
{
  if ( amplitude <= 0.0 || rate <= 0.0 ) {
    oStream_ << "BlowBotl::startBowing: one or more arguments is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setAttackRate( rate );
  maxPressure_ = amplitude;
  adsr_.keyOn();
}

void BlowBotl :: stopBlowing( StkFloat rate )
{
  if ( rate <= 0.0 ) {
    oStream_ << "BlowBotl::stopBowing: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }

  adsr_.setReleaseRate( rate );
  adsr_.keyOff();
}

void BlowBotl :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  this->setFrequency( frequency );
  startBlowing( 1.1 + (amplitude * 0.20), amplitude * 0.02);
  outputGain_ = amplitude + 0.001;
}

void BlowBotl :: noteOff( StkFloat amplitude )
{
  this->stopBlowing( amplitude * 0.02 );
}

void BlowBotl :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( value < 0 || ( number != 101 && value > 128.0 ) ) {
    oStream_ << "BlowBotl::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if (number == __SK_NoiseLevel_) // 4
    noiseGain_ = normalizedValue * 30.0;
  else if (number == __SK_ModFrequency_) // 11
    vibrato_.setFrequency( normalizedValue * 12.0 );
  else if (number == __SK_ModWheel_) // 1
    vibratoGain_ = normalizedValue * 0.4;
  else if (number == __SK_AfterTouch_Cont_) // 128
    adsr_.setTarget( normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "BlowBotl::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
