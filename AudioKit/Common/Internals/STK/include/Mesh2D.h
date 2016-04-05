#ifndef STK_MESH2D_H
#define STK_MESH2D_H

#include "Instrmnt.h"
#include "OnePole.h"

namespace stk {

/***************************************************/
/*! \class Mesh2D
    \brief Two-dimensional rectilinear waveguide mesh class.

    This class implements a rectilinear,
    two-dimensional digital waveguide mesh
    structure.  For details, see Van Duyne and
    Smith, "Physical Modeling with the 2-D Digital
    Waveguide Mesh", Proceedings of the 1993
    International Computer Music Conference.

    This is a digital waveguide model, making its
    use possibly subject to patents held by Stanford
    University, Yamaha, and others.

    Control Change Numbers: 
       - X Dimension = 2
       - Y Dimension = 4
       - Mesh Decay = 11
       - X-Y Input Position = 1

    by Julius Smith, 2000 - 2002.
    Revised by Gary Scavone for STK, 2002.
*/
/***************************************************/

const unsigned short NXMAX = 12;
const unsigned short NYMAX = 12;

class Mesh2D : public Instrmnt
{
 public:
  //! Class constructor, taking the x and y dimensions in samples.
  Mesh2D( unsigned short nX, unsigned short nY );

  //! Class destructor.
  ~Mesh2D( void );

  //! Reset and clear all internal state.
  void clear( void );

  //! Set the x dimension size in samples.
  void setNX( unsigned short lenX );

  //! Set the y dimension size in samples.
  void setNY( unsigned short lenY );

  //! Set the x, y input position on a 0.0 - 1.0 scale.
  void setInputPosition( StkFloat xFactor, StkFloat yFactor );

  //! Set the loss filters gains (0.0 - 1.0).
  void setDecay( StkFloat decayFactor );

  //! Impulse the mesh with the given amplitude (frequency ignored).
  void noteOn( StkFloat frequency, StkFloat amplitude );

  //! Stop a note with the given amplitude (speed of decay) ... currently ignored.
  void noteOff( StkFloat amplitude );

  //! Calculate and return the signal energy stored in the mesh.
  StkFloat energy( void );

  //! Input a sample to the mesh and compute one output sample.
  StkFloat inputTick( StkFloat input );

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

 protected:

  StkFloat tick0();
  StkFloat tick1();
  void clearMesh();

  unsigned short NX_, NY_;
  unsigned short xInput_, yInput_;
  OnePole  filterX_[NXMAX];
  OnePole  filterY_[NYMAX];
  StkFloat v_[NXMAX-1][NYMAX-1]; // junction velocities
  StkFloat vxp_[NXMAX][NYMAX];   // positive-x velocity wave
  StkFloat vxm_[NXMAX][NYMAX];   // negative-x velocity wave
  StkFloat vyp_[NXMAX][NYMAX];   // positive-y velocity wave
  StkFloat vym_[NXMAX][NYMAX];   // negative-y velocity wave

  // Alternate buffers
  StkFloat vxp1_[NXMAX][NYMAX];  // positive-x velocity wave
  StkFloat vxm1_[NXMAX][NYMAX];  // negative-x velocity wave
  StkFloat vyp1_[NXMAX][NYMAX];  // positive-y velocity wave
  StkFloat vym1_[NXMAX][NYMAX];  // negative-y velocity wave

  int counter_; // time in samples
};

inline StkFrames& Mesh2D :: tick( StkFrames& frames, unsigned int channel )
{
  unsigned int nChannels = lastFrame_.channels();
#if defined(_STK_DEBUG_)
  if ( channel > frames.channels() - nChannels ) {
    oStream_ << "Mesh2D::tick(): channel and StkFrames arguments are incompatible!";
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
