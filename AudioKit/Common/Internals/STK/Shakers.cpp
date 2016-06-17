/***************************************************/
/*! \class Shakers
    \brief PhISEM and PhOLIES class.

    PhISEM (Physically Informed Stochastic Event Modeling) is an
    algorithmic approach for simulating collisions of multiple
    independent sound producing objects.  This class is a meta-model
    that can simulate a Maraca, Sekere, Cabasa, Bamboo Wind Chimes,
    Water Drops, Tambourine, Sleighbells, and a Guiro.

    PhOLIES (Physically-Oriented Library of Imitated Environmental
    Sounds) is a similar approach for the synthesis of environmental
    sounds.  This class implements simulations of breaking sticks,
    crunchy snow (or not), a wrench, sandpaper, and more.

    Control Change Numbers: 
      - Shake Energy = 2
      - System Decay = 4
      - Number Of Objects = 11
      - Resonance Frequency = 1
      - Shake Energy = 128
      - Instrument Selection = 1071
        - Maraca = 0
        - Cabasa = 1
        - Sekere = 2
        - Tambourine = 3
        - Sleigh Bells = 4
        - Bamboo Chimes = 5
        - Sand Paper = 6
        - Coke Can = 7
        - Sticks = 8
        - Crunch = 9
        - Big Rocks = 10
        - Little Rocks = 11
        - Next Mug = 12
        - Penny + Mug = 13
        - Nickle + Mug = 14
        - Dime + Mug = 15
        - Quarter + Mug = 16
        - Franc + Mug = 17
        - Peso + Mug = 18
        - Guiro = 19
        - Wrench = 20
        - Water Drops = 21
        - Tuned Bamboo Chimes = 22

    by Perry R. Cook with updates by Gary Scavone, 1995--2016.
*/
/***************************************************/

#include "Shakers.h"
#include "SKINImsg.h"

namespace stk {

// Maraca
const StkFloat MARACA_SOUND_DECAY = 0.95;
const StkFloat MARACA_SYSTEM_DECAY = 0.999;
const StkFloat MARACA_GAIN = 4.0;
const StkFloat MARACA_NUM_BEANS = 25;
const int MARACA_RESONANCES = 1;
const StkFloat MARACA_FREQUENCIES[MARACA_RESONANCES] = { 3200 };
const StkFloat MARACA_RADII[MARACA_RESONANCES] = { 0.96 };
const StkFloat MARACA_GAINS[MARACA_RESONANCES] = { 1.0 };

// Cabasa
const StkFloat CABASA_SOUND_DECAY = 0.96;
const StkFloat CABASA_SYSTEM_DECAY = 0.997;
const StkFloat CABASA_GAIN = 8.0;
const StkFloat CABASA_NUM_BEADS = 512;
const int CABASA_RESONANCES = 1;
const StkFloat CABASA_FREQUENCIES[CABASA_RESONANCES] = { 3000 };
const StkFloat CABASA_RADII[CABASA_RESONANCES] = { 0.7 };
const StkFloat CABASA_GAINS[CABASA_RESONANCES] = { 1.0 };

// Sekere
const StkFloat SEKERE_SOUND_DECAY = 0.96;
const StkFloat SEKERE_SYSTEM_DECAY = 0.999;
const StkFloat SEKERE_GAIN = 4.0;
const StkFloat SEKERE_NUM_BEANS = 64;
const int SEKERE_RESONANCES = 1;
const StkFloat SEKERE_FREQUENCIES[SEKERE_RESONANCES] = { 5500 };
const StkFloat SEKERE_RADII[SEKERE_RESONANCES] = { 0.6 };
const StkFloat SEKERE_GAINS[SEKERE_RESONANCES] = { 1.0 };

// Bamboo Wind Chimes
const StkFloat BAMBOO_SOUND_DECAY = 0.9;
const StkFloat BAMBOO_SYSTEM_DECAY = 0.9999;
const StkFloat BAMBOO_GAIN = 0.4;
const StkFloat BAMBOO_NUM_TUBES = 1.2;
const int BAMBOO_RESONANCES = 3;
const StkFloat BAMBOO_FREQUENCIES[BAMBOO_RESONANCES] = { 2800, 0.8 * 2800.0, 1.2 * 2800.0 };
const StkFloat BAMBOO_RADII[BAMBOO_RESONANCES] = { 0.995, 0.995, 0.995 };
const StkFloat BAMBOO_GAINS[BAMBOO_RESONANCES] = { 1.0, 1.0, 1.0 };

// Tambourine
const StkFloat TAMBOURINE_SOUND_DECAY = 0.95;
const StkFloat TAMBOURINE_SYSTEM_DECAY = 0.9985;
const StkFloat TAMBOURINE_GAIN = 1.0;
const StkFloat TAMBOURINE_NUM_TIMBRELS = 32;
const int TAMBOURINE_RESONANCES = 3; // Fixed shell + 2 moving cymbal resonances
const StkFloat TAMBOURINE_FREQUENCIES[TAMBOURINE_RESONANCES] = { 2300, 5600, 8100 };
const StkFloat TAMBOURINE_RADII[TAMBOURINE_RESONANCES] = { 0.96, 0.99, 0.99 };
const StkFloat TAMBOURINE_GAINS[TAMBOURINE_RESONANCES] = { 0.1, 0.8, 1.0 };

// Sleighbells
const StkFloat SLEIGH_SOUND_DECAY = 0.97;
const StkFloat SLEIGH_SYSTEM_DECAY = 0.9994;
const StkFloat SLEIGH_GAIN = 1.0;
const StkFloat SLEIGH_NUM_BELLS = 32;
const int SLEIGH_RESONANCES = 5;
const StkFloat SLEIGH_FREQUENCIES[SLEIGH_RESONANCES] = { 2500, 5300, 6500, 8300, 9800 };
const StkFloat SLEIGH_RADII[SLEIGH_RESONANCES] = { 0.99, 0.99, 0.99, 0.99, 0.99 };
const StkFloat SLEIGH_GAINS[SLEIGH_RESONANCES] = { 1.0, 1.0, 1.0, 0.5, 0.3 };

// Sandpaper
const StkFloat SANDPAPER_SOUND_DECAY = 0.999;
const StkFloat SANDPAPER_SYSTEM_DECAY = 0.999;
const StkFloat SANDPAPER_GAIN = 0.5;
const StkFloat SANDPAPER_NUM_GRAINS = 128;
const int SANDPAPER_RESONANCES = 1;
const StkFloat SANDPAPER_FREQUENCIES[SANDPAPER_RESONANCES] = { 4500 };
const StkFloat SANDPAPER_RADII[SANDPAPER_RESONANCES] = { 0.6 };
const StkFloat SANDPAPER_GAINS[SANDPAPER_RESONANCES] = { 1.0 };

// Cokecan
const StkFloat COKECAN_SOUND_DECAY = 0.97;
const StkFloat COKECAN_SYSTEM_DECAY = 0.999;
const StkFloat COKECAN_GAIN = 0.5;
const StkFloat COKECAN_NUM_PARTS = 48;
const int COKECAN_RESONANCES = 5; // Helmholtz + 4 metal resonances
const StkFloat COKECAN_FREQUENCIES[COKECAN_RESONANCES] = { 370, 1025, 1424, 2149, 3596 };
const StkFloat COKECAN_RADII[COKECAN_RESONANCES] = { 0.99, 0.992, 0.992, 0.992, 0.992 };
const StkFloat COKECAN_GAINS[COKECAN_RESONANCES] = { 1.0, 1.8, 1.8, 1.8, 1.8 };

// Tuned Bamboo Wind Chimes (Angklung)
const StkFloat ANGKLUNG_SOUND_DECAY = 0.95;
const StkFloat ANGKLUNG_SYSTEM_DECAY = 0.9999;
const StkFloat ANGKLUNG_GAIN = 0.5;
const StkFloat ANGKLUNG_NUM_TUBES = 1.2;
const int ANGKLUNG_RESONANCES = 7;
const StkFloat ANGKLUNG_FREQUENCIES[ANGKLUNG_RESONANCES] = { 1046.6, 1174.8, 1397.0, 1568, 1760, 2093.3, 2350 };
const StkFloat ANGKLUNG_RADII[ANGKLUNG_RESONANCES] = { 0.996, 0.996, 0.996, 0.996, 0.996, 0.996, 0.996 };
const StkFloat ANGKLUNG_GAINS[ANGKLUNG_RESONANCES] = { 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 };

// Guiro
const StkFloat GUIRO_SOUND_DECAY = 0.95;
const StkFloat GUIRO_GAIN = 0.4;
const StkFloat GUIRO_NUM_PARTS = 128;
const int GUIRO_RESONANCES = 2;
const StkFloat GUIRO_FREQUENCIES[GUIRO_RESONANCES] = { 2500, 4000 };
const StkFloat GUIRO_RADII[GUIRO_RESONANCES] = { 0.97, 0.97 };
const StkFloat GUIRO_GAINS[GUIRO_RESONANCES] = { 1.0, 1.0 };

// Wrench
const StkFloat WRENCH_SOUND_DECAY = 0.95;
const StkFloat WRENCH_GAIN = 0.4;
const StkFloat WRENCH_NUM_PARTS = 128;
const int WRENCH_RESONANCES = 2;
const StkFloat WRENCH_FREQUENCIES[WRENCH_RESONANCES] = { 3200, 8000 };
const StkFloat WRENCH_RADII[WRENCH_RESONANCES] = { 0.99, 0.992 };
const StkFloat WRENCH_GAINS[WRENCH_RESONANCES] = { 1.0, 1.0 };

// Water Drops
const StkFloat WATER_SOUND_DECAY = 0.95;
const StkFloat WATER_SYSTEM_DECAY = 0.996;
const StkFloat WATER_GAIN = 1.0;
const StkFloat WATER_NUM_SOURCES = 10;
const int WATER_RESONANCES = 3;
const StkFloat WATER_FREQUENCIES[WATER_RESONANCES] = { 450, 600, 750 };
const StkFloat WATER_RADII[WATER_RESONANCES] = { 0.9985, 0.9985, 0.9985 };
const StkFloat WATER_GAINS[WATER_RESONANCES] = { 1.0, 1.0, 1.0 };

// PhOLIES (Physically-Oriented Library of Imitated Environmental
// Sounds), Perry Cook, 1997-8

// Stix1
const StkFloat STIX1_SOUND_DECAY = 0.96;
const StkFloat STIX1_SYSTEM_DECAY = 0.998;
const StkFloat STIX1_GAIN = 6.0;
const StkFloat STIX1_NUM_BEANS = 2;
const int STIX1_RESONANCES = 1;
const StkFloat STIX1_FREQUENCIES[STIX1_RESONANCES] = { 5500 };
const StkFloat STIX1_RADII[STIX1_RESONANCES] = { 0.6 };
const StkFloat STIX1_GAINS[STIX1_RESONANCES] = { 1.0 };

// Crunch1
const StkFloat CRUNCH1_SOUND_DECAY = 0.95;
const StkFloat CRUNCH1_SYSTEM_DECAY = 0.99806;
const StkFloat CRUNCH1_GAIN = 4.0;
const StkFloat CRUNCH1_NUM_BEADS = 7;
const int CRUNCH1_RESONANCES = 1;
const StkFloat CRUNCH1_FREQUENCIES[CRUNCH1_RESONANCES] = { 800 };
const StkFloat CRUNCH1_RADII[CRUNCH1_RESONANCES] = { 0.95 };
const StkFloat CRUNCH1_GAINS[CRUNCH1_RESONANCES] = { 1.0 };

// Nextmug + Coins
const StkFloat NEXTMUG_SOUND_DECAY = 0.97;
const StkFloat NEXTMUG_SYSTEM_DECAY = 0.9995;
const StkFloat NEXTMUG_GAIN = 0.8;
const StkFloat NEXTMUG_NUM_PARTS = 3;
const int NEXTMUG_RESONANCES = 4;
const StkFloat NEXTMUG_FREQUENCIES[NEXTMUG_RESONANCES] = { 2123, 4518, 8856, 10753 };
const StkFloat NEXTMUG_RADII[NEXTMUG_RESONANCES] = { 0.997, 0.997, 0.997, 0.997 };
const StkFloat NEXTMUG_GAINS[NEXTMUG_RESONANCES] = { 1.0, 0.8, 0.6, 0.4 };

const int COIN_RESONANCES = 3;
const StkFloat PENNY_FREQUENCIES[COIN_RESONANCES] = { 11000, 5200, 3835 };
const StkFloat PENNY_RADII[COIN_RESONANCES] = { 0.999, 0.999, 0.999 };
const StkFloat PENNY_GAINS[COIN_RESONANCES] = { 1.0, 0.8, 0.5 };

const StkFloat NICKEL_FREQUENCIES[COIN_RESONANCES] = { 5583, 9255, 9805 };
const StkFloat NICKEL_RADII[COIN_RESONANCES] = { 0.9992, 0.9992, 0.9992 };
const StkFloat NICKEL_GAINS[COIN_RESONANCES] = { 1.0, 0.8, 0.5 };

const StkFloat DIME_FREQUENCIES[COIN_RESONANCES] = { 4450, 4974, 9945 };
const StkFloat DIME_RADII[COIN_RESONANCES] = { 0.9993, 0.9993, 0.9993 };
const StkFloat DIME_GAINS[COIN_RESONANCES] = { 1.0, 0.8, 0.5 };

const StkFloat QUARTER_FREQUENCIES[COIN_RESONANCES] = { 1708, 8863, 9045 };
const StkFloat QUARTER_RADII[COIN_RESONANCES] = { 0.9995, 0.9995, 0.9995 };
const StkFloat QUARTER_GAINS[COIN_RESONANCES] = { 1.0, 0.8, 0.5 };

const StkFloat FRANC_FREQUENCIES[COIN_RESONANCES] = { 5583, 11010, 1917 };
const StkFloat FRANC_RADII[COIN_RESONANCES] = { 0.9995, 0.9995, 0.9995 };
const StkFloat FRANC_GAINS[COIN_RESONANCES] = { 0.7, 0.4, 0.3 };

const StkFloat PESO_FREQUENCIES[COIN_RESONANCES] = { 7250, 8150, 10060 };
const StkFloat PESO_RADII[COIN_RESONANCES] = { 0.9996, 0.9996, 0.9996 };
const StkFloat PESO_GAINS[COIN_RESONANCES] = { 1.0, 1.2, 0.7 };

// Big Gravel
const StkFloat BIGROCKS_SOUND_DECAY = 0.98;
const StkFloat BIGROCKS_SYSTEM_DECAY = 0.9965;
const StkFloat BIGROCKS_GAIN = 4.0;
const StkFloat BIGROCKS_NUM_PARTS = 23;
const int BIGROCKS_RESONANCES = 1;
const StkFloat BIGROCKS_FREQUENCIES[BIGROCKS_RESONANCES] = { 6460 };
const StkFloat BIGROCKS_RADII[BIGROCKS_RESONANCES] = { 0.932 };
const StkFloat BIGROCKS_GAINS[BIGROCKS_RESONANCES] = { 1.0 };

// Little Gravel
const StkFloat LITTLEROCKS_SOUND_DECAY = 0.98;
const StkFloat LITTLEROCKS_SYSTEM_DECAY = 0.99586;
const StkFloat LITTLEROCKS_GAIN = 4.0;
const StkFloat LITTLEROCKS_NUM_PARTS = 1600;
const int LITTLEROCKS_RESONANCES = 1;
const StkFloat LITTLEROCKS_FREQUENCIES[LITTLEROCKS_RESONANCES] = { 9000 };
const StkFloat LITTLEROCKS_RADII[LITTLEROCKS_RESONANCES] = { 0.843 };
const StkFloat LITTLEROCKS_GAINS[LITTLEROCKS_RESONANCES] = { 1.0 };

Shakers :: Shakers( int type )
{
  shakerType_ = -1;
  this->setType( type );
}

void Shakers :: setType( int type )
{
  if ( shakerType_ == type ) return;
  varyFactor_ = 0.0;
  shakerType_ = type;
  if ( type == 1 ) { // Cabasa
    nResonances_ = CABASA_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = CABASA_NUM_BEADS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = CABASA_RADII[i];
      baseFrequencies_[i] = CABASA_FREQUENCIES[i];
      filters_[i].gain = CABASA_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = CABASA_SYSTEM_DECAY;
    baseGain_ = CABASA_GAIN;
    soundDecay_ = CABASA_SOUND_DECAY;
    decayScale_ = 0.97;
    setEqualization( 1.0, -1.0, 0.0 );
  }
  else if ( type == 2 ) { // Sekere
    nResonances_ = SEKERE_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = SEKERE_NUM_BEANS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = SEKERE_RADII[i];
      baseFrequencies_[i] = SEKERE_FREQUENCIES[i];
      filters_[i].gain = SEKERE_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = SEKERE_SYSTEM_DECAY;
    baseGain_ = SEKERE_GAIN;
    soundDecay_ = SEKERE_SOUND_DECAY;
    decayScale_ = 0.94;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 3 ) { // Tambourine
    nResonances_ = TAMBOURINE_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = TAMBOURINE_NUM_TIMBRELS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = TAMBOURINE_RADII[i];
      baseFrequencies_[i] = TAMBOURINE_FREQUENCIES[i];
      filters_[i].gain = TAMBOURINE_GAINS[i];
      doVaryFrequency_[i] = true;
    }
    doVaryFrequency_[0] = false;
    baseDecay_ = TAMBOURINE_SYSTEM_DECAY;
    baseGain_ = TAMBOURINE_GAIN;
    soundDecay_ = TAMBOURINE_SOUND_DECAY;
    decayScale_ = 0.95;
    varyFactor_ = 0.05;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 4 ) { // Sleighbells
    nResonances_ = SLEIGH_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = SLEIGH_NUM_BELLS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = SLEIGH_RADII[i];
      baseFrequencies_[i] = SLEIGH_FREQUENCIES[i];
      filters_[i].gain = SLEIGH_GAINS[i];
      doVaryFrequency_[i] = true;
    }
    baseDecay_ = SLEIGH_SYSTEM_DECAY;
    baseGain_ = SLEIGH_GAIN;
    soundDecay_ = SLEIGH_SOUND_DECAY;
    decayScale_ = 0.9;
    varyFactor_ = 0.03;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 5 ) { // Bamboo chimes
    nResonances_ = BAMBOO_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = BAMBOO_NUM_TUBES;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = BAMBOO_RADII[i];
      baseFrequencies_[i] = BAMBOO_FREQUENCIES[i];
      filters_[i].gain = BAMBOO_GAINS[i];
      doVaryFrequency_[i] = true;
    }
    baseDecay_ = BAMBOO_SYSTEM_DECAY;
    baseGain_ = BAMBOO_GAIN;
    soundDecay_ = BAMBOO_SOUND_DECAY;
    decayScale_ = 0.7;
    varyFactor_ = 0.2;
    setEqualization( 1.0, 0.0, 0.0 );
  }
  else if ( type == 6 ) { // Sandpaper
    nResonances_ = SANDPAPER_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = SANDPAPER_NUM_GRAINS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = SANDPAPER_RADII[i];
      baseFrequencies_[i] = SANDPAPER_FREQUENCIES[i];
      filters_[i].gain = SANDPAPER_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = SANDPAPER_SYSTEM_DECAY;
    baseGain_ = SANDPAPER_GAIN;
    soundDecay_ = SANDPAPER_SOUND_DECAY;
    decayScale_ = 0.97;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 7 ) { // Cokecan
    nResonances_ = COKECAN_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = COKECAN_NUM_PARTS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = COKECAN_RADII[i];
      baseFrequencies_[i] = COKECAN_FREQUENCIES[i];
      filters_[i].gain = COKECAN_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = COKECAN_SYSTEM_DECAY;
    baseGain_ = COKECAN_GAIN;
    soundDecay_ = COKECAN_SOUND_DECAY;
    decayScale_ = 0.95;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 8 ) { // Stix1
    nResonances_ = STIX1_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = STIX1_NUM_BEANS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = STIX1_RADII[i];
      baseFrequencies_[i] = STIX1_FREQUENCIES[i];
      filters_[i].gain = STIX1_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = STIX1_SYSTEM_DECAY;
    baseGain_ = STIX1_GAIN;
    soundDecay_ = STIX1_SOUND_DECAY;
    decayScale_ = 0.96;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 9 ) { // Crunch1
    nResonances_ = CRUNCH1_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = CRUNCH1_NUM_BEADS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = CRUNCH1_RADII[i];
      baseFrequencies_[i] = CRUNCH1_FREQUENCIES[i];
      filters_[i].gain = CRUNCH1_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = CRUNCH1_SYSTEM_DECAY;
    baseGain_ = CRUNCH1_GAIN;
    soundDecay_ = CRUNCH1_SOUND_DECAY;
    decayScale_ = 0.96;
    setEqualization( 1.0, -1.0, 0.0 );
  }
  else if ( type == 10 ) { // Big Rocks
    nResonances_ = BIGROCKS_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = BIGROCKS_NUM_PARTS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = BIGROCKS_RADII[i];
      baseFrequencies_[i] = BIGROCKS_FREQUENCIES[i];
      filters_[i].gain = BIGROCKS_GAINS[i];
      doVaryFrequency_[i] = true;
    }
    baseDecay_ = BIGROCKS_SYSTEM_DECAY;
    baseGain_ = BIGROCKS_GAIN;
    soundDecay_ = BIGROCKS_SOUND_DECAY;
    decayScale_ = 0.95;
    varyFactor_ = 0.11;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 11 ) { // Little Rocks
    nResonances_ = LITTLEROCKS_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = LITTLEROCKS_NUM_PARTS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = LITTLEROCKS_RADII[i];
      baseFrequencies_[i] = LITTLEROCKS_FREQUENCIES[i];
      filters_[i].gain = LITTLEROCKS_GAINS[i];
      doVaryFrequency_[i] = true;
    }
    baseDecay_ = LITTLEROCKS_SYSTEM_DECAY;
    baseGain_ = LITTLEROCKS_GAIN;
    soundDecay_ = LITTLEROCKS_SOUND_DECAY;
    decayScale_ = 0.95;
    varyFactor_ = 0.18;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type > 11 && type < 19 ) { // Nextmug
    nResonances_ = NEXTMUG_RESONANCES;
    if ( type > 12 )  // mug + coin
      nResonances_ += COIN_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = NEXTMUG_NUM_PARTS;
    for ( int i=0; i<NEXTMUG_RESONANCES; i++ ) {
      baseRadii_[i] = NEXTMUG_RADII[i];
      baseFrequencies_[i] = NEXTMUG_FREQUENCIES[i];
      filters_[i].gain = NEXTMUG_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = NEXTMUG_SYSTEM_DECAY;
    baseGain_ = NEXTMUG_GAIN;
    soundDecay_ = NEXTMUG_SOUND_DECAY;
    decayScale_ = 0.95;
    setEqualization( 1.0, 0.0, -1.0 );

    // Add coins
    if ( type == 13 ) { // Mug + Penny
      for ( int i=0; i<COIN_RESONANCES; i++ ) {
        baseRadii_[i+NEXTMUG_RESONANCES] = PENNY_RADII[i];
        baseFrequencies_[i+NEXTMUG_RESONANCES] = PENNY_FREQUENCIES[i];
        filters_[i+NEXTMUG_RESONANCES].gain = PENNY_GAINS[i];
        doVaryFrequency_[i+NEXTMUG_RESONANCES] = false;
      }
    }
    else if ( type == 14 ) { // Mug + Nickel
      for ( int i=0; i<COIN_RESONANCES; i++ ) {
        baseRadii_[i+NEXTMUG_RESONANCES] = NICKEL_RADII[i];
        baseFrequencies_[i+NEXTMUG_RESONANCES] = NICKEL_FREQUENCIES[i];
        filters_[i+NEXTMUG_RESONANCES].gain = NICKEL_GAINS[i];
        doVaryFrequency_[i+NEXTMUG_RESONANCES] = false;
      }
    }
    else if ( type == 15 ) { // Mug + Dime
      for ( int i=0; i<COIN_RESONANCES; i++ ) {
        baseRadii_[i+NEXTMUG_RESONANCES] = DIME_RADII[i];
        baseFrequencies_[i+NEXTMUG_RESONANCES] = DIME_FREQUENCIES[i];
        filters_[i+NEXTMUG_RESONANCES].gain = DIME_GAINS[i];
        doVaryFrequency_[i+NEXTMUG_RESONANCES] = false;
      }
    }
    else if ( type == 16 ) { // Mug + Quarter
      for ( int i=0; i<COIN_RESONANCES; i++ ) {
        baseRadii_[i+NEXTMUG_RESONANCES] = QUARTER_RADII[i];
        baseFrequencies_[i+NEXTMUG_RESONANCES] = QUARTER_FREQUENCIES[i];
        filters_[i+NEXTMUG_RESONANCES].gain = QUARTER_GAINS[i];
        doVaryFrequency_[i+NEXTMUG_RESONANCES] = false;
      }
    }
    else if ( type == 17 ) { // Mug + Franc
      for ( int i=0; i<COIN_RESONANCES; i++ ) {
        baseRadii_[i+NEXTMUG_RESONANCES] = FRANC_RADII[i];
        baseFrequencies_[i+NEXTMUG_RESONANCES] = FRANC_FREQUENCIES[i];
        filters_[i+NEXTMUG_RESONANCES].gain = FRANC_GAINS[i];
        doVaryFrequency_[i+NEXTMUG_RESONANCES] = false;
      }
    }
    else if ( type == 18 ) { // Mug + Peso
      for ( int i=0; i<COIN_RESONANCES; i++ ) {
        baseRadii_[i+NEXTMUG_RESONANCES] = PESO_RADII[i];
        baseFrequencies_[i+NEXTMUG_RESONANCES] = PESO_FREQUENCIES[i];
        filters_[i+NEXTMUG_RESONANCES].gain = PESO_GAINS[i];
        doVaryFrequency_[i+NEXTMUG_RESONANCES] = false;
      }
    }
  }
  else if ( type == 19 ) { // Guiro
    nResonances_ = GUIRO_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = GUIRO_NUM_PARTS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = GUIRO_RADII[i];
      baseFrequencies_[i] = GUIRO_FREQUENCIES[i];
      filters_[i].gain = GUIRO_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseGain_ = GUIRO_GAIN;
    soundDecay_ = GUIRO_SOUND_DECAY;
    ratchetCount_ = 0;
    baseRatchetDelta_ = 0.0001;
    ratchetDelta_ = baseRatchetDelta_;
    lastRatchetValue_ = -1;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 20 ) { // Wrench
    nResonances_ = WRENCH_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = WRENCH_NUM_PARTS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = WRENCH_RADII[i];
      baseFrequencies_[i] = WRENCH_FREQUENCIES[i];
      filters_[i].gain = WRENCH_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseGain_ = WRENCH_GAIN;
    soundDecay_ = WRENCH_SOUND_DECAY;
    ratchetCount_ = 0;
    baseRatchetDelta_ = 0.00015;
    ratchetDelta_ = baseRatchetDelta_;
    lastRatchetValue_ = -1;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else if ( type == 21 ) { // Water Drops
    nResonances_ = WATER_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    tempFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = WATER_NUM_SOURCES;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = WATER_RADII[i];
      baseFrequencies_[i] = WATER_FREQUENCIES[i];
      tempFrequencies_[i] = WATER_FREQUENCIES[i];
      filters_[i].gain = WATER_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = WATER_SYSTEM_DECAY;
    baseGain_ = WATER_GAIN;
    soundDecay_ = WATER_SOUND_DECAY;
    decayScale_ = 0.8;
    setEqualization( -1.0, 0.0, 1.0 );
  }
  else if ( type == 22 ) { // Tuned Bamboo Chimes (Angklung)
    nResonances_ = ANGKLUNG_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = ANGKLUNG_NUM_TUBES;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = ANGKLUNG_RADII[i];
      baseFrequencies_[i] = ANGKLUNG_FREQUENCIES[i];
      filters_[i].gain = ANGKLUNG_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = ANGKLUNG_SYSTEM_DECAY;
    baseGain_ = ANGKLUNG_GAIN;
    soundDecay_ = ANGKLUNG_SOUND_DECAY;
    decayScale_ = 0.7;
    setEqualization( 1.0, 0.0, -1.0 );
  }
  else { // Maraca (default)
    shakerType_ = 0;
    nResonances_ = MARACA_RESONANCES;
    filters_.resize( nResonances_ );
    baseFrequencies_.resize( nResonances_ );
    baseRadii_.resize( nResonances_ );
    doVaryFrequency_.resize( nResonances_ );
    baseObjects_ = MARACA_NUM_BEANS;
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      baseRadii_[i] = MARACA_RADII[i];
      baseFrequencies_[i] = MARACA_FREQUENCIES[i];
      filters_[i].gain = MARACA_GAINS[i];
      doVaryFrequency_[i] = false;
    }
    baseDecay_ = MARACA_SYSTEM_DECAY;
    baseGain_ = MARACA_GAIN;
    soundDecay_ = MARACA_SOUND_DECAY;
    decayScale_ = 0.97;
    setEqualization( 1.0, -1.0, 0.0 );
  }

  // Set common algorithm variables.
  shakeEnergy_ = 0.0;
  sndLevel_ = 0.0;
  nObjects_ = baseObjects_;
  systemDecay_ = baseDecay_;
  currentGain_ = log( nObjects_ ) * baseGain_ / nObjects_;

  for ( unsigned int i=0; i<nResonances_; i++ )
    setResonance( filters_[i], baseFrequencies_[i], baseRadii_[i] );
}

const StkFloat MAX_SHAKE = 1.0;

void Shakers :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  // Yep ... pretty kludgey, but it works!
  int noteNumber = (int) ((12 * log(frequency/220.0)/log(2.0)) + 57.01) % 32;
  if ( shakerType_ != noteNumber ) this->setType( noteNumber );

  shakeEnergy_ += amplitude * MAX_SHAKE * 0.1;
  if ( shakeEnergy_ > MAX_SHAKE ) shakeEnergy_ = MAX_SHAKE;
  if ( shakerType_==19 || shakerType_==20 ) ratchetCount_ += 1;
}

void Shakers :: noteOff( StkFloat amplitude )
{
  shakeEnergy_ = 0.0;
  if ( shakerType_==19 || shakerType_==20 ) ratchetCount_ = 0;
}

void Shakers :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Shakers::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if ( number == __SK_Breath_ || number == __SK_AfterTouch_Cont_ ) { // 2 or 128 ... energy
    if ( shakerType_ == 19 || shakerType_ == 20 ) {
      if ( lastRatchetValue_ < 0.0 ) ratchetCount_++;
      else ratchetCount_ = (int) fabs(value - lastRatchetValue_);
      ratchetDelta_ = baseRatchetDelta_ * ratchetCount_;
      lastRatchetValue_ = (int) value;
    }
    else {
      shakeEnergy_ += normalizedValue * MAX_SHAKE * 0.1;
      if ( shakeEnergy_ > MAX_SHAKE ) shakeEnergy_ = MAX_SHAKE;
    }
  }
  else if ( number == __SK_ModFrequency_ ) { // 4 ... decay
    systemDecay_ = baseDecay_ + ( 2.0 * (normalizedValue - 0.5) * decayScale_ * (1.0 - baseDecay_) );
  }
  else if ( number == __SK_FootControl_ ) { // 11 ... number of objects
    nObjects_ = (StkFloat) ( 2.0 * normalizedValue * baseObjects_ ) + 1.1;
    currentGain_ = log( nObjects_ ) * baseGain_ / nObjects_;
  }
  else if ( number == __SK_ModWheel_ ) { // 1 ... resonance frequency
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      StkFloat temp = baseFrequencies_[i] * pow( 4.0, normalizedValue-0.5 );
      setResonance( filters_[i], temp, baseRadii_[i] );
    }
  }
  else  if (number == __SK_ShakerInst_) { // 1071
    unsigned int type = (unsigned int) (value + 0.5);	//  Just to be safe
    this->setType( type );
  }
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Shakers::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
