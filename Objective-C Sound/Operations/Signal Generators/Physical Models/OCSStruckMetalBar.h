//
//  OCSStruckMetalBar.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Creates a tone similar to a struck metal bar.
 
 Audio output is a tone similar to a struck metal bar, using a physical model developed from solving the partial differential equation. There are controls over the boundary conditions as well as the bar characteristics.
 */

@interface OCSStruckMetalBar : OCSAudio

/// Instantiates the struck metal bar
/// @param decayTime 30 db decay time in seconds.
/// @param dimensionlessStiffness Dimensionless stiffness parameter. If this parameter is negative then the initialization is skipped and the previous state of the bar is continued.
/// @param highFrequencyLoss high-frequency loss parameter (keep this small).
/// @param strikePosition Position along the bar that the strike occurs.
/// @param strikeVelocity Normalized strike velocity.
/// @param strikeWidth Spatial width of strike.
/// @param leftBoundaryCondition Boundary condition at left end of bar (1 is clamped; 2 pivoting and 3 free).
/// @param rightBoundaryCondition Boundary condition at right end of bar (1 is clamped; 2 pivoting and 3 free).
/// @param scanSpeed Speed of scanning the output location.
- (instancetype)initWithDecayTime:(OCSConstant *)decayTime
 dimensionlessStiffness:(OCSConstant *)dimensionlessStiffness
      highFrequencyLoss:(OCSConstant *)highFrequencyLoss
         strikePosition:(OCSConstant *)strikePosition
         strikeVelocity:(OCSConstant *)strikeVelocity
            strikeWidth:(OCSConstant *)strikeWidth
  leftBoundaryCondition:(OCSControl *)leftBoundaryCondition
 rightBoundaryCondition:(OCSControl *)rightBoundaryCondition
              scanSpeed:(OCSControl *)scanSpeed;

@end
