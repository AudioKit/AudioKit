//
//  AKStruckMetalBar.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/29/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Creates a tone similar to a struck metal bar.
 
 Audio output is a tone similar to a struck metal bar, using a physical model developed from solving the partial differential equation. There are controls over the boundary conditions as well as the bar characteristics.
 */

@interface AKStruckMetalBar : AKAudio

/// Instantiates the struck metal bar with all values
/// @param decayTime 30 db decay time in seconds.
/// @param dimensionlessStiffness Dimensionless stiffness parameter. If this parameter is negative then the initialization is skipped and the previous state of the bar is continued.
/// @param highFrequencyLoss High-frequency loss parameter (keep this small).
/// @param strikePosition Position along the bar that the strike occurs.
/// @param strikeVelocity Normalized strike velocity.
/// @param strikeWidth Spatial width of strike.
/// @param leftBoundaryCondition Boundary condition at left end of bar (1 is clamped; 2 pivoting and 3 free).
/// @param rightBoundaryCondition Boundary condition at right end of bar (1 is clamped; 2 pivoting and 3 free).
/// @param scanSpeed Speed of scanning the output location.
- (instancetype)initWithDecayTime:(AKConstant *)decayTime
           dimensionlessStiffness:(AKConstant *)dimensionlessStiffness
                highFrequencyLoss:(AKConstant *)highFrequencyLoss
                   strikePosition:(AKConstant *)strikePosition
                   strikeVelocity:(AKConstant *)strikeVelocity
                      strikeWidth:(AKConstant *)strikeWidth
            leftBoundaryCondition:(AKControl *)leftBoundaryCondition
           rightBoundaryCondition:(AKControl *)rightBoundaryCondition
                        scanSpeed:(AKControl *)scanSpeed;

/// Instantiates the struck metal bar with default values
- (instancetype)init;


/// Instantiates the struck metal bar with default values
+ (instancetype)audio;




/// 30 db decay time in seconds. [Default Value: 2.0]
@property AKConstant *decayTime;

/// Set an optional decay time
/// @param decayTime 30 db decay time in seconds. [Default Value: 2.0]
- (void)setOptionalDecayTime:(AKConstant *)decayTime;


/// Dimensionless stiffness parameter. If this parameter is negative then the initialization is skipped and the previous state of the bar is continued. [Default Value: 100]
@property AKConstant *dimensionlessStiffness;

/// Set an optional dimensionless stiffness
/// @param dimensionlessStiffness Dimensionless stiffness parameter. If this parameter is negative then the initialization is skipped and the previous state of the bar is continued. [Default Value: 100]
- (void)setOptionalDimensionlessStiffness:(AKConstant *)dimensionlessStiffness;


/// High-frequency loss parameter (keep this small). [Default Value: 0.001]
@property AKConstant *highFrequencyLoss;

/// Set an optional high frequency loss
/// @param highFrequencyLoss High-frequency loss parameter (keep this small). [Default Value: 0.001]
- (void)setOptionalHighFrequencyLoss:(AKConstant *)highFrequencyLoss;


/// Position along the bar that the strike occurs. [Default Value: 0.2]
@property AKConstant *strikePosition;

/// Set an optional strike position
/// @param strikePosition Position along the bar that the strike occurs. [Default Value: 0.2]
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition;


/// Normalized strike velocity. [Default Value: 800]
@property AKConstant *strikeVelocity;

/// Set an optional strike velocity
/// @param strikeVelocity Normalized strike velocity. [Default Value: 800]
- (void)setOptionalStrikeVelocity:(AKConstant *)strikeVelocity;


/// Spatial width of strike. [Default Value: 0.2]
@property AKConstant *strikeWidth;

/// Set an optional strike width
/// @param strikeWidth Spatial width of strike. [Default Value: 0.2]
- (void)setOptionalStrikeWidth:(AKConstant *)strikeWidth;


/// Boundary condition at left end of bar (1 is clamped; 2 pivoting and 3 free). [Default Value: 1]
@property AKControl *leftBoundaryCondition;

/// Set an optional left boundary condition
/// @param leftBoundaryCondition Boundary condition at left end of bar (1 is clamped; 2 pivoting and 3 free). [Default Value: 1]
- (void)setOptionalLeftBoundaryCondition:(AKControl *)leftBoundaryCondition;


/// Boundary condition at right end of bar (1 is clamped; 2 pivoting and 3 free). [Default Value: 1]
@property AKControl *rightBoundaryCondition;

/// Set an optional right boundary condition
/// @param rightBoundaryCondition Boundary condition at right end of bar (1 is clamped; 2 pivoting and 3 free). [Default Value: 1]
- (void)setOptionalRightBoundaryCondition:(AKControl *)rightBoundaryCondition;


/// Speed of scanning the output location. [Default Value: 0.23]
@property AKControl *scanSpeed;

/// Set an optional scan speed
/// @param scanSpeed Speed of scanning the output location. [Default Value: 0.23]
- (void)setOptionalScanSpeed:(AKControl *)scanSpeed;


@end
