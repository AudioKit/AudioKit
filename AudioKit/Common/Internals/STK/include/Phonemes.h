#ifndef STK_PHONEMES_H
#define STK_PHONEMES_H

#include "Stk.h"

namespace stk {

/***************************************************/
/*! \class Phonemes
    \brief STK phonemes table.

    This class does nothing other than declare a
    set of 32 static phoneme formant parameters
    and provide access to those values.

    by Perry R. Cook and Gary P. Scavone, 1995--2016.
*/
/***************************************************/

class Phonemes : public Stk
{
public:

  Phonemes( void );

  ~Phonemes( void );

  //! Returns the phoneme name for the given index (0-31).
  static const char *name( unsigned int index );

  //! Returns the voiced component gain for the given phoneme index (0-31).
  static StkFloat voiceGain( unsigned int index );

  //! Returns the unvoiced component gain for the given phoneme index (0-31).
  static StkFloat noiseGain( unsigned int index );

  //! Returns the formant frequency for the given phoneme index (0-31) and partial (0-3).
  static StkFloat formantFrequency( unsigned int index, unsigned int partial );

  //! Returns the formant radius for the given phoneme index (0-31) and partial (0-3).
  static StkFloat formantRadius( unsigned int index, unsigned int partial );

  //! Returns the formant gain for the given phoneme index (0-31) and partial (0-3).
  static StkFloat formantGain( unsigned int index, unsigned int partial );

private:

  static const char phonemeNames[][4];
  static const StkFloat phonemeGains[][2];
  static const StkFloat phonemeParameters[][4][3];
};

} // stk namespace

#endif
