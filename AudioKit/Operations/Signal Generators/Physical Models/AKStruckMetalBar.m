//
//  AKStruckMetalBar.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/29/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's barmodel:
//  http://www.csounds.com/manual/html/barmodel.html
//

#import "AKStruckMetalBar.h"
#import "AKManager.h"

@implementation AKStruckMetalBar

- (instancetype)initWithDecayTime:(AKConstant *)decayTime
           dimensionlessStiffness:(AKConstant *)dimensionlessStiffness
                highFrequencyLoss:(AKConstant *)highFrequencyLoss
                   strikePosition:(AKConstant *)strikePosition
                   strikeVelocity:(AKConstant *)strikeVelocity
                      strikeWidth:(AKConstant *)strikeWidth
            leftBoundaryCondition:(AKControl *)leftBoundaryCondition
           rightBoundaryCondition:(AKControl *)rightBoundaryCondition
                        scanSpeed:(AKControl *)scanSpeed
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
        _leftBoundaryCondition = akp(1);
        _rightBoundaryCondition = akp(1);
        _scanSpeed = akp(0.23);
    }
    return self;
}

+ (instancetype)audio
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

- (void)setOptionalLeftBoundaryCondition:(AKControl *)leftBoundaryCondition {
    _leftBoundaryCondition = leftBoundaryCondition;
}

- (void)setOptionalRightBoundaryCondition:(AKControl *)rightBoundaryCondition {
    _rightBoundaryCondition = rightBoundaryCondition;
}

- (void)setOptionalScanSpeed:(AKControl *)scanSpeed {
    _scanSpeed = scanSpeed;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ barmodel %@, %@, %@, %@, %@, %@, %@, %@, %@",
            self,
            _leftBoundaryCondition,
            _rightBoundaryCondition,
            _dimensionlessStiffness,
            _highFrequencyLoss,
            _scanSpeed,
            _decayTime,
            _strikePosition,
            _strikeVelocity,
            _strikeWidth];
}


@end
