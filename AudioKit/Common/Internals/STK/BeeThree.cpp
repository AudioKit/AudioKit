/***************************************************/
/*! \class BeeThree
    \brief STK Hammond-oid organ FM synthesis instrument.

    This class implements a simple 4 operator
    topology, also referred to as algorithm 8 of
    the TX81Z.

    \code
    Algorithm 8 is :
                     1 --.
                     2 -\|
                         +-> Out
                     3 -/|
                     4 --
    \endcode

    Control Change Numbers: 
       - Operator 4 (feedback) Gain = 2
       - Operator 3 Gain = 4
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

#include "BeeThree.h"

namespace stk {

BeeThree :: BeeThree( void )
  : FM()
{
  // Concatenate the STK rawwave path to the rawwave files
  for ( unsigned int i=0; i<3; i++ )
    waves_[i] = new FileLoop( (Stk::rawwavePath() + "sinewave.raw").c_str(), true );
  waves_[3] = new FileLoop( (Stk::rawwavePath() + "fwavblnk.raw").c_str(), true );

  this->setRatio( 0, 0.999 );
  this->setRatio( 1, 1.997 );
  this->setRatio( 2, 3.006 );
  this->setRatio( 3, 6.009 );

  gains_[0] = fmGains_[95];
  gains_[1] = fmGains_[95];
  gains_[2] = fmGains_[99];
  gains_[3] = fmGains_[95];

  adsr_[0]->setAllTimes( 0.005, 0.003, 1.0, 0.01 );
  adsr_[1]->setAllTimes( 0.005, 0.003, 1.0, 0.01 );
  adsr_[2]->setAllTimes( 0.005, 0.003, 1.0, 0.01 );
  adsr_[3]->setAllTimes( 0.005, 0.001, 0.4, 0.03 );

  twozero_.setGain( 0.1 );
}  

BeeThree :: ~BeeThree( void )
{
}

void BeeThree :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  gains_[0] = amplitude * fmGains_[95];
  gains_[1] = amplitude * fmGains_[95];
  gains_[2] = amplitude * fmGains_[99];
  gains_[3] = amplitude * fmGains_[95];
  this->setFrequency( frequency );
  this->keyOn();
}

} // stk namespace
