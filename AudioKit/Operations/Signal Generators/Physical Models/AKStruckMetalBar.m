//
//  AKStruckMetalBar.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's barmodel:
//  http://www.csounds.com/manual/html/barmodel.html
//

#import "AKStruckMetalBar.h"
#import "AKManager.h"

@implementation AKStruckMetalBar

+ (AKConstant *)boundaryConditionClamped  { return akp(1); }
+ (AKConstant *)boundaryConditionPivoting { return akp(2); }
+ (AKConstant *)boundaryConditionFree     { return akp(3); }

- (instancetype)initWithDecayTime:(AKConstant *)decayTime
           dimensionlessStiffness:(AKConstant *)dimensionlessStiffness
                highFrequencyLoss:(AKConstant *)highFrequencyLoss
                   strikePosition:(AKConstant *)strikePosition
                   strikeVelocity:(AKConstant *)strikeVelocity
                      strikeWidth:(AKConstant *)strikeWidth
            leftBoundaryCondition:(AKConstant *)leftBoundaryCondition
           rightBoundaryCondition:(AKConstant *)rightBoundaryCondition
                        scanSpeed:(AKParameter *)scanSpeed
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _decayTime = decayTime;
        _dimensionlessStiffness = dimensionlessStiffness;
        _highFrequencyLoss = highFrequencyLoss;
        _strikePosition = strikePosition;
        _strikeVelocity = strikeVelocity;
        _strikeWidth = strikeWidth;
        _leftBoundaryCondition = leftBoundaryCondition;
        _rightBoundaryCondition = rightBoundaryCondition;
        _scanSpeed = scanSpeed;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _decayTime = akp(2.0);
        _dimensionlessStiffness = akp(100);
        _highFrequencyLoss = akp(0.001);
        _strikePosition = akp(0.2);
        _strikeVelocity = akp(800);
        _strikeWidth = akp(0.2);
        _leftBoundaryCondition  = [AKStruckMetalBar boundaryConditionClamped];
        _rightBoundaryCondition = [AKStruckMetalBar boundaryConditionClamped];
        _scanSpeed = akp(0.23);
    }
    return self;
}

+ (instancetype)strike
{
    return [[AKStruckMetalBar alloc] init];
}

- (void)setOptionalDecayTime:(AKConstant *)decayTime {
    _decayTime = decayTime;
}
- (void)setOptionalDimensionlessStiffness:(AKConstant *)dimensionlessStiffness {
    _dimensionlessStiffness = dimensionlessStiffness;
}
- (void)setOptionalHighFrequencyLoss:(AKConstant *)highFrequencyLoss {
    _highFrequencyLoss = highFrequencyLoss;
}
- (void)setOptionalStrikePosition:(AKConstant *)strikePosition {
    _strikePosition = strikePosition;
}
- (void)setOptionalStrikeVelocity:(AKConstant *)strikeVelocity {
    _strikeVelocity = strikeVelocity;
}
- (void)setOptionalStrikeWidth:(AKConstant *)strikeWidth {
    _strikeWidth = strikeWidth;
}
- (void)setOptionalLeftBoundaryCondition:(AKConstant *)leftBoundaryCondition {
    _leftBoundaryCondition = leftBoundaryCondition;
}
- (void)setOptionalRightBoundaryCondition:(AKConstant *)rightBoundaryCondition {
    _rightBoundaryCondition = rightBoundaryCondition;
}
- (void)setOptionalScanSpeed:(AKParameter *)scanSpeed {
    _scanSpeed = scanSpeed;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ barmodel ", self];

    [csdString appendFormat:@"%@, ", _leftBoundaryCondition];
    
    [csdString appendFormat:@"%@, ", _rightBoundaryCondition];
    
    [csdString appendFormat:@"%@, ", _dimensionlessStiffness];
    
    [csdString appendFormat:@"%@, ", _highFrequencyLoss];
    
    if ([_scanSpeed class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _scanSpeed];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _scanSpeed];
    }

    [csdString appendFormat:@"%@, ", _decayTime];
    
    [csdString appendFormat:@"%@, ", _strikePosition];
    
    [csdString appendFormat:@"%@, ", _strikeVelocity];
    
    [csdString appendFormat:@"%@", _strikeWidth];
    return csdString;
}

@end
