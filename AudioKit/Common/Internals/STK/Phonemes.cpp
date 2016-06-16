/***************************************************/
/*! \class Phonemes
    \brief STK phonemes table.

    This class does nothing other than declare a
    set of 32 static phoneme formant parameters
    and provide access to those values.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

#include "Phonemes.h"
#include <iostream>

namespace stk {

const char Phonemes :: phonemeNames[32][4] = 
  {"eee", "ihh", "ehh", "aaa",
   "ahh", "aww", "ohh", "uhh",
   "uuu", "ooo", "rrr", "lll",
   "mmm", "nnn", "nng", "ngg",
   "fff", "sss", "thh", "shh",
   "xxx", "hee", "hoo", "hah",
   "bbb", "ddd", "jjj", "ggg",
   "vvv", "zzz", "thz", "zhh"
  };

const StkFloat Phonemes :: phonemeGains[32][2] =
  {{1.0, 0.0},    // eee
   {1.0, 0.0},    // ihh
   {1.0, 0.0},    // ehh
   {1.0, 0.0},    // aaa

   {1.0, 0.0},    // ahh
   {1.0, 0.0},    // aww
   {1.0, 0.0},    // ohh
   {1.0, 0.0},    // uhh

   {1.0, 0.0},    // uuu
   {1.0, 0.0},    // ooo
   {1.0, 0.0},    // rrr
   {1.0, 0.0},    // lll

   {1.0, 0.0},    // mmm
   {1.0, 0.0},    // nnn
   {1.0, 0.0},    // nng
   {1.0, 0.0},    // ngg

   {0.0, 0.7},    // fff
   {0.0, 0.7},    // sss
   {0.0, 0.7},    // thh
   {0.0, 0.7},    // shh

   {0.0, 0.7},    // xxx
   {0.0, 0.1},    // hee
   {0.0, 0.1},    // hoo
   {0.0, 0.1},    // hah

   {1.0, 0.1},    // bbb
   {1.0, 0.1},    // ddd
   {1.0, 0.1},    // jjj
   {1.0, 0.1},    // ggg

   {1.0, 1.0},    // vvv
   {1.0, 1.0},    // zzz
   {1.0, 1.0},    // thz
   {1.0, 1.0}     // zhh
  };

const StkFloat Phonemes :: phonemeParameters[32][4][3] =
  {{  { 273, 0.996,  10},       // eee (beet)
      {2086, 0.945, -16}, 
      {2754, 0.979, -12}, 
      {3270, 0.440, -17}},
   {  { 385, 0.987,  10},       // ihh (bit)
      {2056, 0.930, -20},
      {2587, 0.890, -20}, 
      {3150, 0.400, -20}},
   {  { 515, 0.977,  10},       // ehh (bet)
      {1805, 0.810, -10}, 
      {2526, 0.875, -10}, 
      {3103, 0.400, -13}},
   {  { 773, 0.950,  10},       // aaa (bat)
      {1676, 0.830,  -6},
      {2380, 0.880, -20}, 
      {3027, 0.600, -20}},
     
   {  { 770, 0.950,   0},       // ahh (father)
      {1153, 0.970,  -9},
      {2450, 0.780, -29},
      {3140, 0.800, -39}},
   {  { 637, 0.910,   0},       // aww (bought)
      { 895, 0.900,  -3},
      {2556, 0.950, -17},
      {3070, 0.910, -20}},
   {  { 637, 0.910,   0},       // ohh (bone)  NOTE::  same as aww (bought)
      { 895, 0.900,  -3},
      {2556, 0.950, -17},
      {3070, 0.910, -20}},
   {  { 561, 0.965,   0},       // uhh (but)
      {1084, 0.930, -10}, 
      {2541, 0.930, -15}, 
      {3345, 0.900, -20}},
    
   {  { 515, 0.976,   0},       // uuu (foot)
      {1031, 0.950,  -3},
      {2572, 0.960, -11},
      {3345, 0.960, -20}},
   {  { 349, 0.986, -10},       // ooo (boot)
      { 918, 0.940, -20},
      {2350, 0.960, -27},
      {2731, 0.950, -33}},
   {  { 394, 0.959, -10},       // rrr (bird)
      {1297, 0.780, -16},
      {1441, 0.980, -16},
      {2754, 0.950, -40}},
   {  { 462, 0.990,  +5},       // lll (lull)
      {1200, 0.640, -10},
      {2500, 0.200, -20},
      {3000, 0.100, -30}},
     
   {  { 265, 0.987, -10},       // mmm (mom)
      {1176, 0.940, -22},
      {2352, 0.970, -20},
      {3277, 0.940, -31}},
   {  { 204, 0.980, -10},       // nnn (nun)
      {1570, 0.940, -15},
      {2481, 0.980, -12},
      {3133, 0.800, -30}},
   {  { 204, 0.980, -10},       // nng (sang)    NOTE:: same as nnn
      {1570, 0.940, -15},
      {2481, 0.980, -12},
      {3133, 0.800, -30}},
   {  { 204, 0.980, -10},       // ngg (bong)    NOTE:: same as nnn
      {1570, 0.940, -15},
      {2481, 0.980, -12},
      {3133, 0.800, -30}},
     
   {  {1000, 0.300,   0},       // fff
      {2800, 0.860, -10},
      {7425, 0.740,   0},
      {8140, 0.860,   0}},
   {  {0,    0.000,   0},       // sss
      {2000, 0.700, -15},
      {5257, 0.750,  -3}, 
      {7171, 0.840,   0}},
   {  { 100, 0.900,   0},       // thh
      {4000, 0.500, -20},
      {5500, 0.500, -15},
      {8000, 0.400, -20}},
   {  {2693, 0.940,   0},       // shh
      {4000, 0.720, -10},
      {6123, 0.870, -10},
      {7755, 0.750, -18}},

   {  {1000, 0.300, -10},       // xxx           NOTE:: Not Really Done Yet
      {2800, 0.860, -10},
      {7425, 0.740,   0},
      {8140, 0.860,   0}},
   {  { 273, 0.996, -40},       // hee (beet)    (noisy eee)
      {2086, 0.945, -16}, 
      {2754, 0.979, -12}, 
      {3270, 0.440, -17}},
   {  { 349, 0.986, -40},       // hoo (boot)    (noisy ooo)
      { 918, 0.940, -10},
      {2350, 0.960, -17},
      {2731, 0.950, -23}},
   {  { 770, 0.950, -40},       // hah (father)  (noisy ahh)
      {1153, 0.970,  -3},
      {2450, 0.780, -20},
      {3140, 0.800, -32}},
     
   {  {2000, 0.700, -20},       // bbb           NOTE:: Not Really Done Yet
      {5257, 0.750, -15},
      {7171, 0.840,  -3}, 
      {9000, 0.900,   0}},
   {  { 100, 0.900,   0},       // ddd           NOTE:: Not Really Done Yet
      {4000, 0.500, -20},
      {5500, 0.500, -15},
      {8000, 0.400, -20}},
   {  {2693, 0.940,   0},       // jjj           NOTE:: Not Really Done Yet
      {4000, 0.720, -10},
      {6123, 0.870, -10},
      {7755, 0.750, -18}},
   {  {2693, 0.940,   0},       // ggg           NOTE:: Not Really Done Yet
      {4000, 0.720, -10},
      {6123, 0.870, -10},
      {7755, 0.750, -18}},
     
   {  {2000, 0.700, -20},       // vvv           NOTE:: Not Really Done Yet
      {5257, 0.750, -15},
      {7171, 0.840,  -3}, 
      {9000, 0.900,   0}},
   {  { 100, 0.900,   0},       // zzz           NOTE:: Not Really Done Yet
      {4000, 0.500, -20},
      {5500, 0.500, -15},
      {8000, 0.400, -20}},
   {  {2693, 0.940,   0},       // thz           NOTE:: Not Really Done Yet
      {4000, 0.720, -10},
      {6123, 0.870, -10},
      {7755, 0.750, -18}},
   {  {2693, 0.940,   0},       // zhh           NOTE:: Not Really Done Yet
      {4000, 0.720, -10},
      {6123, 0.870, -10},
      {7755, 0.750, -18}}
  };

Phonemes :: Phonemes(void)
{
}

Phonemes :: ~Phonemes(void)
{
}

const char *Phonemes :: name( unsigned int index )
{
  if ( index > 31 ) {
    oStream_ << "Phonemes::name: index is greater than 31!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0;
  }
  return phonemeNames[index];
}

StkFloat Phonemes :: voiceGain( unsigned int index )
{
  if ( index > 31 ) {
    oStream_ << "Phonemes::voiceGain: index is greater than 31!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  return phonemeGains[index][0];
}

StkFloat Phonemes :: noiseGain( unsigned int index )
{
  if ( index > 31 ) {
    oStream_ << "Phonemes::noiseGain: index is greater than 31!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  return phonemeGains[index][1];
}

StkFloat Phonemes :: formantFrequency( unsigned int index, unsigned int partial )
{
  if ( index > 31 ) {
    oStream_ << "Phonemes::formantFrequency: index is greater than 31!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  if ( partial > 3 ) {
    oStream_ << "Phonemes::formantFrequency: partial is greater than 3!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  return phonemeParameters[index][partial][0];
}

StkFloat Phonemes :: formantRadius( unsigned int index, unsigned int partial )
{
  if ( index > 31 ) {
    oStream_ << "Phonemes::formantRadius: index is greater than 31!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  if ( partial > 3 ) {
    oStream_ << "Phonemes::formantRadius: partial is greater than 3!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  return phonemeParameters[index][partial][1];
}

StkFloat Phonemes :: formantGain( unsigned int index, unsigned int partial )
{
  if ( index > 31 ) {
    oStream_ << "Phonemes::formantGain: index is greater than 31!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  if ( partial > 3 ) {
    oStream_ << "Phonemes::formantGain: partial is greater than 3!";
    handleError( oStream_.str(), StkError::WARNING );
    return 0.0;
  }
  return phonemeParameters[index][partial][2];
}

} // stk namespace
