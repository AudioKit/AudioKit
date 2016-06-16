#ifndef STK_SHAKERS_H
#define STK_SHAKERS_H

#include "Instrmnt.h"
#include <cmath>
#include <stdlib.h>

namespace stk {

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

class Shakers : public Instrmnt
{
 public:
  //! Class constructor taking instrument type argument.
  Shakers( int type = 0 );

  //! Start a note with the given instrument and amplitude.
  /*!
    Use the instrument numbers above, converted to frequency values
    as if MIDI note numbers, to select a particular instrument.
  */
  void noteOn( StkFloat instrument, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay).
  void noteOff( StkFloat amplitude );

  //! Perform the control change specified by \e number and \e value (0.0 - 128.0).
  void controlChange( int number, StkFloat value );

  //! Compute and return one output sample.
  StkFloat tick( unsigned int channel = 0 );

  //! Fill a channel of the StkFrames object with computed outputs.
  /*!
    The \c channel argument must be less than the number of
    channels in the StkFrames argument (the first channel is specified
    by 0).  However, range checking is only performed if _STK_DEBUG_
    is defined during compilation, in which case an out-of-range value
    will trigger an StkError exception.
  */
  StkFrames& tick( StkFrames& frames, unsigned int channel = 0 );

  struct BiQuad {
    StkFloat gain;
    StkFloat b[3];
    StkFloat a[3]; // a0 term assumed equal to 1.0
    StkFloat inputs[3];
    StkFloat outputs[3];

    // Default constructor.
    BiQuad()
    {
      gain = 0.0;
      for ( int i=0; i<3; i++ ) {
        b[i] = 0.0;
        a[i] = 0.0;
        inputs[i] = 0.0;
        outputs[i] = 0.0;
      }
    }
  };

 protected:

  void setType( int type );
  void setResonance( BiQuad &filter, StkFloat frequency, StkFloat radius );
  StkFloat tickResonance( BiQuad &filter, StkFloat input );
  void setEqualization( StkFloat b0, StkFloat b1, StkFloat b2 );
  StkFloat tickEqualize( StkFloat input );
  int randomInt( int max );
  StkFloat randomFloat( StkFloat max = 1.0 );
  StkFloat noise( void );
  void waterDrop( void );

  int shakerType_;
  unsigned int nResonances_;
  StkFloat shakeEnergy_;
  StkFloat soundDecay_;
  StkFloat systemDecay_;
  StkFloat nObjects_;
  StkFloat sndLevel_;
  StkFloat baseGain_;
  StkFloat currentGain_;
  StkFloat baseDecay_;
  StkFloat baseObjects_;
  StkFloat decayScale_;
  BiQuad equalizer_;
  StkFloat ratchetCount_;
  StkFloat ratchetDelta_;
  StkFloat baseRatchetDelta_;
  int lastRatchetValue_;

  std::vector< BiQuad > filters_;
  std::vector< StkFloat > baseFrequencies_;
  std::vector< StkFloat > baseRadii_;
  std::vector< bool > doVaryFrequency_;
  std::vector< StkFloat > tempFrequencies_;
  StkFloat varyFactor_;
};

inline void Shakers :: setResonance( BiQuad &filter, StkFloat frequency, StkFloat radius )
{
  filter.a[1] = -2.0 * radius * cos( TWO_PI * frequency / Stk::sampleRate());
  filter.a[2] = radius * radius;
}

inline StkFloat Shakers :: tickResonance( BiQuad &filter, StkFloat input )
{
  filter.outputs[0] = input * filter.gain * currentGain_;
  filter.outputs[0] -= filter.a[1] * filter.outputs[1] + filter.a[2] * filter.outputs[2];
  filter.outputs[2] = filter.outputs[1];
  filter.outputs[1] = filter.outputs[0];
  return filter.outputs[0];
}

inline void Shakers :: setEqualization( StkFloat b0, StkFloat b1, StkFloat b2 )
{
  equalizer_.b[0] = b0;
  equalizer_.b[1] = b1;
  equalizer_.b[2] = b2;
}

inline StkFloat Shakers :: tickEqualize( StkFloat input )
{
  equalizer_.inputs[0] = input;
  equalizer_.outputs[0] = equalizer_.b[0] * equalizer_.inputs[0] + equalizer_.b[1] * equalizer_.inputs[1] + equalizer_.b[2] * equalizer_.inputs[2];
  equalizer_.inputs[2] = equalizer_.inputs[1];
  equalizer_.inputs[1] = equalizer_.inputs[0];
  return equalizer_.outputs[0];
}

inline int Shakers :: randomInt( int max ) //  Return random integer between 0 and max-1
{
  return (int) ((float)max * rand() / (RAND_MAX + 1.0) );
}

inline StkFloat Shakers :: randomFloat( StkFloat max ) // Return random float between 0.0 and max
{	
  return (StkFloat) (max * rand() / (RAND_MAX + 1.0) );
}

inline StkFloat Shakers :: noise( void ) //  Return random StkFloat float between -1.0 and 1.0
{
  return ( (StkFloat) ( 2.0 * rand() / (RAND_MAX + 1.0) ) - 1.0 );
}

const StkFloat MIN_ENERGY = 0.001;
const StkFloat WATER_FREQ_SWEEP = 1.0001;

inline void Shakers :: waterDrop( void )
{
  if ( randomInt( 32767 ) < nObjects_) {
    sndLevel_ = shakeEnergy_;   
    unsigned int j = randomInt( 3 );
    if ( j == 0 && filters_[0].gain == 0.0 ) { // don't change unless fully decayed
      tempFrequencies_[0] = baseFrequencies_[1] * (0.75 + (0.25 * noise()));
      filters_[0].gain = fabs( noise() );
    }
    else if (j == 1 && filters_[1].gain == 0.0) {
      tempFrequencies_[1] = baseFrequencies_[1] * (1.0 + (0.25 * noise()));
      filters_[1].gain = fabs( noise() );
    }
    else if ( filters_[2].gain == 0.0 ) {
      tempFrequencies_[2] = baseFrequencies_[1] * (1.25 + (0.25 * noise()));
      filters_[2].gain = fabs( noise() );
    }
  }

  // Sweep center frequencies.
  for ( unsigned int i=0; i<3; i++ ) { // WATER_RESONANCES = 3
    filters_[i].gain *= baseRadii_[i];
    if ( filters_[i].gain > 0.001 ) {
      tempFrequencies_[i] *= WATER_FREQ_SWEEP;
      filters_[i].a[1] = -2.0 * baseRadii_[i] * cos( TWO_PI * tempFrequencies_[i] / Stk::sampleRate() );
    }
    else
      filters_[i].gain = 0.0;
  }
}

inline StkFloat Shakers :: tick( unsigned int )
{
  unsigned int iTube = 0;
  StkFloat input = 0.0;
  if ( shakerType_ == 19 || shakerType_ == 20 ) {
    if ( ratchetCount_ <= 0 ) return lastFrame_[0] = 0.0;

    shakeEnergy_ -= ( ratchetDelta_ + ( 0.002 * shakeEnergy_ ) );
    if ( shakeEnergy_ < 0.0 ) {
      shakeEnergy_ = 1.0;
      ratchetCount_--;
    }

    if ( randomFloat( 1024 ) < nObjects_ )
      sndLevel_ += shakeEnergy_ * shakeEnergy_;

    // Sound is enveloped noise
    input = sndLevel_ * noise() * shakeEnergy_;
  }
  else { 
    if ( shakeEnergy_ < MIN_ENERGY ) return lastFrame_[0] = 0.0;

    // Exponential system decay
    shakeEnergy_ *= systemDecay_;

    // Random events
    if ( shakerType_ == 21 ) {
      waterDrop();
      input = sndLevel_;
    }
    else {
      if ( randomFloat( 1024.0 ) < nObjects_ ) {
        sndLevel_ += shakeEnergy_;
        input = sndLevel_;
        // Vary resonance frequencies if specified.
        for ( unsigned int i=0; i<nResonances_; i++ ) {
          if ( doVaryFrequency_[i] ) {
            StkFloat tempRand = baseFrequencies_[i] * ( 1.0 + ( varyFactor_ * noise() ) );
            filters_[i].a[1] = -2.0 * baseRadii_[i] * cos( TWO_PI * tempRand / Stk::sampleRate() );
          }
        }
        if ( shakerType_ == 22 ) iTube = randomInt( 7 ); // ANGKLUNG_RESONANCES
      }
    }
  }

  // Exponential sound decay
  sndLevel_ *= soundDecay_;

  // Do resonance filtering
  lastFrame_[0] = 0.0;
  if ( shakerType_ == 22 ) {
    for ( unsigned int i=0; i<nResonances_; i++ ) {
      if ( i == iTube )
        lastFrame_[0] += tickResonance( filters_[i], input );
      else
        lastFrame_[0] += tickResonance( filters_[i], 0.0 );
    }
  }
  else {
    for ( unsigned int i=0; i<nResonances_; i++ )
      lastFrame_[0] += tickResonance( filters_[i], input );
  }

  // Do final FIR filtering (lowpass or highpass)
  lastFrame_[0] = tickEqualize( lastFrame_[0] );

  //if ( std::abs(lastFrame_[0]) > 1.0 )
  //  std::cout << "lastOutput = " << lastFrame_[0] << std::endl;

  return lastFrame_[0];
}

inline StkFrames& Shakers :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Shakers::tick(): channel and StkFrames arguments are incompatible!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }
#endif

  StkFloat *samples = &frames[channel];
  unsigned int j, hop = frames.channels() - nChannels;
  if ( nChannels == 1 ) {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop )
      *samples++ = tick();
  }
  else {
    for ( unsigned int i=0; i<frames.frames(); i++, samples += hop ) {
      *samples++ = tick();
      for ( j=1; j<nChannels; j++ )
        *samples++ = lastFrame_[j];
    }
  }

  return frames;
}

} // stk namespace

#endif
