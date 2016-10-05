#ifndef STK_VECTOR3D_H
#define STK_VECTOR3D_H

#include "Stk.h"
#include <cmath>

namespace stk {

/***************************************************/
/*! \class Vector3D
    \brief STK 3D vector class.

    This class implements a three-dimensional vector.

    by Perry R. Cook, 1995--2016.
*/
/***************************************************/

class Vector3D : public Stk
{

public:
  //! Default constructor taking optional initial X, Y, and Z values.
  Vector3D( StkFloat x = 0.0, StkFloat y = 0.0, StkFloat z = 0.0 ) { setXYZ( x, y, z ); };

  //! Get the current X value.
  StkFloat getX( void ) { return X_; };

  //! Get the current Y value.
  StkFloat getY( void ) { return Y_; };

  //! Get the current Z value.
  StkFloat getZ( void ) { return Z_; };

  //! Calculate the vector length.
  StkFloat getLength( void );

  //! Set the X, Y, and Z values simultaniously.
  void setXYZ( StkFloat x, StkFloat y, StkFloat z ) { X_ = x; Y_ = y; Z_ = z; };

  //! Set the X value.
  void setX( StkFloat x ) { X_ = x; };

  //! Set the Y value.
  void setY( StkFloat y ) { Y_ = y; };

  //! Set the Z value.
  void setZ( StkFloat z ) { Z_ = z; };

protected:
  StkFloat X_;
  StkFloat Y_;
  StkFloat Z_;
};

inline StkFloat Vector3D :: getLength( void )
{
  StkFloat temp;
  temp = X_ * X_;
  temp += Y_ * Y_;
  temp += Z_ * Z_;
  temp = sqrt( temp );
  return temp;
}

} // stk namespace

#endif
