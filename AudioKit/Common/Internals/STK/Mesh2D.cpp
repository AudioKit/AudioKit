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

#include "Mesh2D.h"
#include "SKINImsg.h"

namespace stk {

Mesh2D :: Mesh2D( unsigned short nX, unsigned short nY )
{
  if ( nX == 0.0 || nY == 0.0 ) {
    oStream_ << "Mesh2D::Mesh2D: one or more argument is equal to zero!";
    handleError( StkError::FUNCTION_ARGUMENT );
  }

  this->setNX( nX );
  this->setNY( nY );

  StkFloat pole = 0.05;
  unsigned short i;
  for ( i=0; i<NYMAX; i++ ) {
    filterY_[i].setPole( pole );
    filterY_[i].setGain( 0.99 );
  }

  for ( i=0; i<NXMAX; i++ ) {
    filterX_[i].setPole( pole );
    filterX_[i].setGain( 0.99 );
  }

  this->clearMesh();

  counter_ = 0;
  xInput_ = 0;
  yInput_ = 0;
}

Mesh2D :: ~Mesh2D( void )
{
}

void Mesh2D :: clear( void )
{
  this->clearMesh();

  unsigned short i;
  for ( i=0; i<NY_; i++ )
    filterY_[i].clear();

  for ( i=0; i<NX_; i++ )
    filterX_[i].clear();

  counter_ = 0;
}

void Mesh2D :: clearMesh( void )
{
  int x, y;
  for ( x=0; x<NXMAX-1; x++ ) {
    for ( y=0; y<NYMAX-1; y++ ) {
      v_[x][y] = 0;
    }
  }
  for ( x=0; x<NXMAX; x++ ) {
    for ( y=0; y<NYMAX; y++ ) {

      vxp_[x][y] = 0;
      vxm_[x][y] = 0;
      vyp_[x][y] = 0;
      vym_[x][y] = 0;

      vxp1_[x][y] = 0;
      vxm1_[x][y] = 0;
      vyp1_[x][y] = 0;
      vym1_[x][y] = 0;
    }
  }
}

StkFloat Mesh2D :: energy( void )
{
  // Return total energy contained in wave variables Note that some
  // energy is also contained in any filter delay elements.

  int x, y;
  StkFloat t;
  StkFloat e = 0;
  if ( counter_ & 1 ) { // Ready for Mesh2D::tick1() to be called.
    for ( x=0; x<NX_; x++ ) {
      for ( y=0; y<NY_; y++ ) {
        t = vxp1_[x][y];
        e += t*t;
        t = vxm1_[x][y];
        e += t*t;
        t = vyp1_[x][y];
        e += t*t;
        t = vym1_[x][y];
        e += t*t;
      }
    }
  }
  else { // Ready for Mesh2D::tick0() to be called.
    for ( x=0; x<NX_; x++ ) {
      for ( y=0; y<NY_; y++ ) {
        t = vxp_[x][y];
        e += t*t;
        t = vxm_[x][y];
        e += t*t;
        t = vyp_[x][y];
        e += t*t;
        t = vym_[x][y];
        e += t*t;
      }
    }
  }

  return e;
}

void Mesh2D :: setNX( unsigned short lenX )
{
  if ( lenX < 2 ) {
    oStream_ << "Mesh2D::setNX(" << lenX << "): Minimum length is 2!";
    handleError( StkError::WARNING ); return;
  }
  else if ( lenX > NXMAX ) {
    oStream_ << "Mesh2D::setNX(" << lenX << "): Maximum length is " << NXMAX << '!';
    handleError( StkError::WARNING ); return;
  }

  NX_ = lenX;
}

void Mesh2D :: setNY( unsigned short lenY )
{
  if ( lenY < 2 ) {
    oStream_ << "Mesh2D::setNY(" << lenY << "): Minimum length is 2!";
    handleError( StkError::WARNING ); return;
  }
  else if ( lenY > NYMAX ) {
    oStream_ << "Mesh2D::setNY(" << lenY << "): Maximum length is " << NXMAX << '!';
    handleError( StkError::WARNING ); return;
  }

  NY_ = lenY;
}

void Mesh2D :: setDecay( StkFloat decayFactor )
{
  if ( decayFactor < 0.0 || decayFactor > 1.0 ) {
    oStream_ << "Mesh2D::setDecay: decayFactor is out of range!";
    handleError( StkError::WARNING ); return;
  }

  int i;
  for ( i=0; i<NYMAX; i++ )
    filterY_[i].setGain( decayFactor );

  for (i=0; i<NXMAX; i++)
    filterX_[i].setGain( decayFactor );
}

void Mesh2D :: setInputPosition( StkFloat xFactor, StkFloat yFactor )
{
  if ( xFactor < 0.0 || xFactor > 1.0 ) {
    oStream_ << "Mesh2D::setInputPosition xFactor value is out of range!";
    handleError( StkError::WARNING ); return;
  }

  if ( yFactor < 0.0 || yFactor > 1.0 ) {
    oStream_ << "Mesh2D::setInputPosition yFactor value is out of range!";
    handleError( StkError::WARNING ); return;
  }

  xInput_ = (unsigned short) (xFactor * (NX_ - 1));
  yInput_ = (unsigned short) (yFactor * (NY_ - 1));
}

void Mesh2D :: noteOn( StkFloat frequency, StkFloat amplitude )
{
  // Input at corner.
  if ( counter_ & 1 ) {
    vxp1_[xInput_][yInput_] += amplitude;
    vyp1_[xInput_][yInput_] += amplitude;
  }
  else {
    vxp_[xInput_][yInput_] += amplitude;
    vyp_[xInput_][yInput_] += amplitude;
  }
}

void Mesh2D :: noteOff( StkFloat amplitude )
{
  return;
}

StkFloat Mesh2D :: inputTick( StkFloat input )
{
  if ( counter_ & 1 ) {
    vxp1_[xInput_][yInput_] += input;
    vyp1_[xInput_][yInput_] += input;
    lastFrame_[0] = tick1();
  }
  else {
    vxp_[xInput_][yInput_] += input;
    vyp_[xInput_][yInput_] += input;
    lastFrame_[0] = tick0();
  }

  counter_++;
  return lastFrame_[0];
}

StkFloat Mesh2D :: tick( unsigned int )
{
  lastFrame_[0] = ((counter_ & 1) ? this->tick1() : this->tick0());
  counter_++;
  return lastFrame_[0];
}

const StkFloat VSCALE = 0.5;

StkFloat Mesh2D :: tick0( void )
{
  int x, y;
  StkFloat outsamp = 0;

  // Update junction velocities.
  for (x=0; x<NX_-1; x++) {
    for (y=0; y<NY_-1; y++) {
      v_[x][y] = ( vxp_[x][y] + vxm_[x+1][y] + 
		  vyp_[x][y] + vym_[x][y+1] ) * VSCALE;
    }
  }    

  // Update junction outgoing waves, using alternate wave-variable buffers.
  for (x=0; x<NX_-1; x++) {
    for (y=0; y<NY_-1; y++) {
      StkFloat vxy = v_[x][y];
      // Update positive-going waves.
      vxp1_[x+1][y] = vxy - vxm_[x+1][y];
      vyp1_[x][y+1] = vxy - vym_[x][y+1];
      // Update minus-going waves.
      vxm1_[x][y] = vxy - vxp_[x][y];
      vym1_[x][y] = vxy - vyp_[x][y];
    }
  }    

  // Loop over velocity-junction boundary faces, update edge
  // reflections, with filtering.  We're only filtering on one x and y
  // edge here and even this could be made much sparser.
  for (y=0; y<NY_-1; y++) {
    vxp1_[0][y] = filterY_[y].tick(vxm_[0][y]);
    vxm1_[NX_-1][y] = vxp_[NX_-1][y];
  }
  for (x=0; x<NX_-1; x++) {
    vyp1_[x][0] = filterX_[x].tick(vym_[x][0]);
    vym1_[x][NY_-1] = vyp_[x][NY_-1];
  }

  // Output = sum of outgoing waves at far corner.  Note that the last
  // index in each coordinate direction is used only with the other
  // coordinate indices at their next-to-last values.  This is because
  // the "unit strings" attached to each velocity node to terminate
  // the mesh are not themselves connected together.
  outsamp = vxp_[NX_-1][NY_-2] + vyp_[NX_-2][NY_-1];

  return outsamp;
}

StkFloat Mesh2D :: tick1( void )
{
  int x, y;
  StkFloat outsamp = 0;

  // Update junction velocities.
  for (x=0; x<NX_-1; x++) {
    for (y=0; y<NY_-1; y++) {
      v_[x][y] = ( vxp1_[x][y] + vxm1_[x+1][y] + 
		  vyp1_[x][y] + vym1_[x][y+1] ) * VSCALE;
    }
  }

  // Update junction outgoing waves, 
  // using alternate wave-variable buffers.
  for (x=0; x<NX_-1; x++) {
    for (y=0; y<NY_-1; y++) {
      StkFloat vxy = v_[x][y];

      // Update positive-going waves.
      vxp_[x+1][y] = vxy - vxm1_[x+1][y];
      vyp_[x][y+1] = vxy - vym1_[x][y+1];

      // Update minus-going waves.
      vxm_[x][y] = vxy - vxp1_[x][y];
      vym_[x][y] = vxy - vyp1_[x][y];
    }
  }

  // Loop over velocity-junction boundary faces, update edge
  // reflections, with filtering.  We're only filtering on one x and y
  // edge here and even this could be made much sparser.
  for (y=0; y<NY_-1; y++) {
    vxp_[0][y] = filterY_[y].tick(vxm1_[0][y]);
    vxm_[NX_-1][y] = vxp1_[NX_-1][y];
  }
  for (x=0; x<NX_-1; x++) {
    vyp_[x][0] = filterX_[x].tick(vym1_[x][0]);
    vym_[x][NY_-1] = vyp1_[x][NY_-1];
  }

  // Output = sum of outgoing waves at far corner.
  outsamp = vxp1_[NX_-1][NY_-2] + vyp1_[NX_-2][NY_-1];

  return outsamp;
}

void Mesh2D :: controlChange( int number, StkFloat value )
{
#if defined(_STK_DEBUG_)
  if ( Stk::inRange( value, 0.0, 128.0 ) == false ) {
    oStream_ << "Mesh2D::controlChange: value (" << value << ") is out of range!";
    handleError( StkError::WARNING ); return;
  }
#endif

  StkFloat normalizedValue = value * ONE_OVER_128;
  if ( number == 2 ) // 2
    this->setNX( (unsigned short) (normalizedValue * (NXMAX-2) + 2) );
  else if ( number == 4 ) // 4
    this->setNY( (unsigned short) (normalizedValue * (NYMAX-2) + 2) );
  else if ( number == 11 ) // 11
    this->setDecay( 0.9 + (normalizedValue * 0.1) );
  else if ( number == __SK_ModWheel_ ) // 1
    this->setInputPosition( normalizedValue, normalizedValue );
#if defined(_STK_DEBUG_)
  else {
    oStream_ << "Mesh2D::controlChange: undefined control number (" << number << ")!";
    handleError( StkError::WARNING );
  }
#endif
}

} // stk namespace
