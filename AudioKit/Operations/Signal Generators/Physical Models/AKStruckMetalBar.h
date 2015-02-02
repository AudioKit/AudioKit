//
//  AKStruckMetalBar.h
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Creates a tone similar to a struck metal bar.

 Audio output is a tone similar to a struck metal bar, using a physical model developed from solving the partial differential equation. There are controls over the boundary conditions as well as the bar characteristics.
More information regarding scanned synthesis can be found at http://dafx12.york.ac.uk/papers/dafx12_submission_18.pdf and http://www.billverplank.com/ScannedSynthesis.PDF
 */

/// Boundary conditions for ends of the struck metal bar physical model
//typedef NS_OPTIONS(NSUInteger, AKStruckMetalBarBoundaryCondition)
//{
//    AKStruckMetalBarBoundaryConditionClamped=1,
//    AKStruckMetalBarBoundaryConditionPivoting=2,
//    AKStruckMetalBarBoundaryConditionFree=3,
//};

@interface AKStruckMetalBar : AKAudio

// TypeHelpers
+ (AKConstant *)boundaryConditionClamped;
+ (AKConstant *)boundaryConditionPivoting;
+ (AKConstant *)boundaryConditionFree;

/// Instantiates the struck metal bar with all values
/// @param decayTime 30 db decay time in seconds. [Default Value: 2.0]
/// @param dimensionlessStiffness Dimensionless stiffness parameter. If this parameter is negative then the initialization is skipped and the previous state of the bar is continued. [Default Value: 100]
/// @param highFrequencyLoss High-frequency loss parameter (keep this small). [Default Value: 0.001]
/// @param strikePosition Position along the bar that the strike occurs. [Default Value: 0.2]
/// @param strikeVelocity Normalized strike velocity. [Default Value: 800]
/// @param strikeWidth Spatial width of strike. [Default Value: 0.2]
/// @param leftBoundaryCondition Boundary condition at left end of bar. [Default Value: AKStruckMetalBarBoundaryConditionClamped]
/// @param rightBoundaryCondition Boundary condition at right end of bar. [Default Value: AKStruckMetalBarBoundaryConditionClamped]
/// @param scanSpeed Speed of scanning the output location. Updated at Control-rate. [Default Value: 0.23]
- (instancetype)initWithDecayTime:(AKConstant *)decayTime
           dimensionlessStiffness:(AKConstant *)dimensionlessStiffness
                highFrequencyLoss:(AKConstant *)highFrequencyLoss
                   strikePosition:(AKConstant *)strikePosition
                   strikeVelocity:(AKConstant *)strikeVelocity
                      strikeWidth:(AKConstant *)strikeWidth
            leftBoundaryCondition:(AKConstant *)leftBoundaryCondition
           rightBoundaryCondition:(AKConstant *)rightBoundaryCondition
                        scanSpeed:(AKParameter *)scanSpeed;

/// Instantiates the struck metal bar with default values
- (instancetype)init;

/// Instantiates the struck metal bar with default values
+ (instancetype)strike;


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

/// Boundary condition at left end of bar. [Default Value: AKStruckMetalBarBoundaryConditionClamped]
@property AKConstant *leftBoundaryCondition;

/// Set an optional left boundary condition
/// @param leftBoundaryCondition Boundary condition at left end of bar. [Default Value: AKStruckMetalBarBoundaryConditionClamped]
- (void)setOptionalLeftBoundaryCondition:(AKConstant *)leftBoundaryCondition;

/// Boundary condition at right end of bar. [Default Value: AKStruckMetalBarBoundaryConditionClamped]
@property AKConstant *rightBoundaryCondition;

/// Set an optional right boundary condition
/// @param rightBoundaryCondition Boundary condition at right end of bar. [Default Value: AKStruckMetalBarBoundaryConditionClamped]
- (void)setOptionalRightBoundaryCondition:(AKConstant *)rightBoundaryCondition;

/// Speed of scanning the output location. [Default Value: 0.23]
@property AKParameter *scanSpeed;

/// Set an optional scan speed
/// @param scanSpeed Speed of scanning the output location. Updated at Control-rate. [Default Value: 0.23]
- (void)setOptionalScanSpeed:(AKParameter *)scanSpeed;



@end
