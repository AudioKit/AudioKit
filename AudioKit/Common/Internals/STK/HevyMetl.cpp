/***************************************************/
/*! \class HevyMetl
    \brief STK heavy metal FM synthesis instrument.

    This class implements 3 cascade operators with
    feedback modulation, also referred to as
    algorithm 3 of the TX81Z.

    Algorithm 3 is :     4--\
                    3-->2-- + -->1-->Out

    Control Change Numbers: 
       - Total Modulator Index = 2
       - Modulator Crossfade = 4
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

#include "HevyMetl.h"

namespace stk {

HevyMetl :: HevyMetl( void )
  : FM()
{
  // Concatenate the STK rawwave path to the rawwave files
  for ( unsigned int i=0; i<3; i++ )
    waves_[i] = new FileLoop( (Stk::rawwavePath() + "sinewave.raw").c_str(), true );
  waves_[3] = new FileLoop( (Stk::rawwavePath() + "fwavblnk.raw").c_str(), true );

  this->setRatio(0, 1.0 * 1.000);
  this->setRatio(1, 4.0 * 0.999);
  this->setRatio(2, 3.0 * 1.001);
  this->setRatio(3, 0.5 * 1.002);

  gains_[0] = fmGains_[92];
  gains_[1] = fmGains_[76];
  gains_[2] = fmGains_[91];
  gains_[3] = fmGains_[68];

  adsr_[0]->setAllTimes( 0.001, 0.001, 1.0, 0.01);
  adsr_[1]->setAllTimes( 0.001, 0.010, 1.0, 0.50);
  adsr_[2]->setAllTimes( 0.010, 0.005, 1.0, 0.20);
  adsr_[3]->setAllTimes( 0.030, 0.010, 0.2, 0.20);

  twozero_.setGain( 2.0 );
  vibrato_.setFrequency( 5.5 );
  modDepth_ = 0.0;
}  

HevyMetl :: ~HevyMetl( void )
{
}

void HevyMetl :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  gains_[0] = amplitude * fmGains_[92];
  gains_[1] = amplitude * fmGains_[76];
  gains_[2] = amplitude * fmGains_[91];
  gains_[3] = amplitude * fmGains_[68];
  this->setFrequency( frequency );
  this->keyOn();
}

} // stk namespace
