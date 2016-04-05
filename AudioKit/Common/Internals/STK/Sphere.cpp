/***************************************************/
/*! \class Sphere
    \brief STK sphere class.

    This class implements a spherical ball with
    radius, mass, position, and velocity parameters.

    by Perry R. Cook, 1995--2016.
*/
/***************************************************/

#include "Sphere.h"
#include <cmath>

namespace stk {

Vector3D* Sphere::getRelativePosition( Vector3D* position )
{
  workingVector_.setXYZ(position->getX() - position_.getX(),
                        position->getY() - position_.getY(),  
                        position->getZ() - position_.getZ());
  return &workingVector_;
};

StkFloat Sphere::getVelocity( Vector3D* velocity )
{
  velocity->setXYZ( velocity_.getX(), velocity_.getY(), velocity_.getZ() );
  return velocity_.getLength();
};

StkFloat Sphere::isInside( Vector3D *position )
{
  // Return directed distance from aPosition to spherical boundary ( <
  // 0 if inside).
  StkFloat distance;
  Vector3D *tempVector;

  tempVector = this->getRelativePosition( position );
  distance = tempVector->getLength();
  return distance - radius_;
};

void Sphere::addVelocity(StkFloat x, StkFloat y, StkFloat z)
{
  velocity_.setX(velocity_.getX() + x);
  velocity_.setY(velocity_.getY() + y);
  velocity_.setZ(velocity_.getZ() + z);
}

} // stk namespace
