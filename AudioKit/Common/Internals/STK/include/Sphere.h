#ifndef STK_SPHERE_H
#define STK_SPHERE_H

#include "Stk.h"
#include "Vector3D.h"

namespace stk {

/***************************************************/
/*! \class Sphere
    \brief STK sphere class.

    This class implements a spherical ball with
    radius, mass, position, and velocity parameters.

    by Perry R. Cook, 1995--2016.
*/
/***************************************************/

class Sphere : public Stk
{
public:
  //! Constructor taking an initial radius value.
  Sphere( StkFloat radius = 1.0 ) { radius_ = radius; mass_ = 1.0; };

  //! Set the 3D center position of the sphere.
  void setPosition( StkFloat x, StkFloat y, StkFloat z ) { position_.setXYZ(x, y, z); };

  //! Set the 3D velocity of the sphere.
  void setVelocity( StkFloat x, StkFloat y, StkFloat z ) { velocity_.setXYZ(x, y, z); };

  //! Set the radius of the sphere.
  void setRadius( StkFloat radius ) { radius_ = radius; };

  //! Set the mass of the sphere.
  void setMass( StkFloat mass ) { mass_ = mass; };

  //! Get the current position of the sphere as a 3D vector.
  Vector3D* getPosition( void ) { return &position_; };

  //! Get the relative position of the given point to the sphere as a 3D vector.
  Vector3D* getRelativePosition( Vector3D *position );

  //! Set the velocity of the sphere as a 3D vector.
  StkFloat getVelocity( Vector3D* velocity );

  //! Returns the distance from the sphere boundary to the given position (< 0 if inside).
  StkFloat isInside( Vector3D *position );

  //! Get the current sphere radius.
  StkFloat getRadius( void ) { return radius_; };

  //! Get the current sphere mass.
  StkFloat getMass( void ) { return mass_; };

  //! Increase the current sphere velocity by the given 3D components.
  void addVelocity( StkFloat x, StkFloat y, StkFloat z );

  //! Move the sphere for the given time increment.
  void tick( StkFloat timeIncrement );
   
private:
  Vector3D position_;
  Vector3D velocity_;
  Vector3D workingVector_;
  StkFloat radius_;
  StkFloat mass_;
};

inline void Sphere::tick( StkFloat timeIncrement )
{
  position_.setX(position_.getX() + (timeIncrement * velocity_.getX()));
  position_.setY(position_.getY() + (timeIncrement * velocity_.getY()));
  position_.setZ(position_.getZ() + (timeIncrement * velocity_.getZ()));
};

} // stk namespace

#endif
