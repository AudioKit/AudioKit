/***************************************************/
/*! \class PercFlut
    \brief STK percussive flute FM synthesis instrument.

    This class implements algorithm 4 of the TX81Z.

    \code
    Algorithm 4 is :   4->3--\
                          2-- + -->1-->Out
    \endcode

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

#include "PercFlut.h"

namespace stk {

PercFlut :: PercFlut( void )
  : FM()
{
  // Concatenate the STK rawwave path to the rawwave files
  for ( unsigned int i=0; i<3; i++ )
    waves_[i] = new FileLoop( (Stk::rawwavePath() + "sinewave.raw").c_str(), true );
  waves_[3] = new FileLoop( (Stk::rawwavePath() + "fwavblnk.raw").c_str(), true );

  this->setRatio(0, 1.50 * 1.000);
  this->setRatio(1, 3.00 * 0.995);
  this->setRatio(2, 2.99 * 1.005);
  this->setRatio(3, 6.00 * 0.997);
  gains_[0] = fmGains_[99];
  gains_[1] = fmGains_[71];
  gains_[2] = fmGains_[93];
  gains_[3] = fmGains_[85];

  adsr_[0]->setAllTimes( 0.05, 0.05, fmSusLevels_[14], 0.05);
  adsr_[1]->setAllTimes( 0.02, 0.50, fmSusLevels_[13], 0.5);
  adsr_[2]->setAllTimes( 0.02, 0.30, fmSusLevels_[11], 0.05);
  adsr_[3]->setAllTimes( 0.02, 0.05, fmSusLevels_[13], 0.01);

  twozero_.setGain( 0.0 );
  modDepth_ = 0.005;
}  

PercFlut :: ~PercFlut( void )
{
}

void PercFlut :: setFrequency( StkFloat frequency )
{    
#if defined(_STK_DEBUG_)
  if ( frequency <= 0.0 ) {
    oStream_ << "PercFlut::setFrequency: argument is less than or equal to zero!";
    handleError( StkError::WARNING ); return;
  }
#endif

  baseFrequency_ = frequency;
}

void PercFlut :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  gains_[0] = amplitude * fmGains_[99] * 0.5;
  gains_[1] = amplitude * fmGains_[71] * 0.5;
  gains_[2] = amplitude * fmGains_[93] * 0.5;
  gains_[3] = amplitude * fmGains_[85] * 0.5;
  this->setFrequency( frequency );
  this->keyOn();
}

} // stk namespace
