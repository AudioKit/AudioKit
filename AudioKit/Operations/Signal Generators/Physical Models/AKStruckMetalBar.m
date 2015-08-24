//
//  AKStruckMetalBar.m
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka to add boundary condition helpers
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
        [self setUpConnections];
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
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)strike
{
    return [[AKStruckMetalBar alloc] init];
}

+ (instancetype)presetDefaultStruckMetalBar
{
    return [[AKStruckMetalBar alloc] init];
}

- (instancetype)initWithPresetThickDullMetalBar
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _decayTime = akp(1.0);
        _dimensionlessStiffness = akp(50);
        _highFrequencyLoss = akp(0.1);
        _strikePosition = akp(0.6);
        _strikeVelocity = akp(2000);
        _strikeWidth = akp(0.2);
        _leftBoundaryCondition  = [AKStruckMetalBar boundaryConditionClamped];
        _rightBoundaryCondition = [AKStruckMetalBar boundaryConditionClamped];
        _scanSpeed = akp(0.23);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetThickDullMetalBar
{
    return [[AKStruckMetalBar alloc] initWithPresetThickDullMetalBar];
}

- (instancetype)initWithPresetIntenseDecayingMetalBar
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _decayTime = akp(5.0);
        _dimensionlessStiffness = akp(100);
        _highFrequencyLoss = akp(0.01);
        _strikePosition = akp(0.2);
        _strikeVelocity = akp(10000);
        _strikeWidth = akp(0.2);
        _leftBoundaryCondition  = [AKStruckMetalBar boundaryConditionClamped];
        _rightBoundaryCondition = [AKStruckMetalBar boundaryConditionClamped];
        _scanSpeed = akp(0.23);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetIntenseDecayingMetalBar
{
    return [[AKStruckMetalBar alloc] initWithPresetIntenseDecayingMetalBar];
}

- (instancetype)initWithPresetSmallHollowMetalBar
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _decayTime = akp(0.1);
        _dimensionlessStiffness = akp(200);
        _highFrequencyLoss = akp(0.1);
        _strikePosition = akp(0.2);
        _strikeVelocity = akp(2000);
        _strikeWidth = akp(0.9);
        _leftBoundaryCondition  = [AKStruckMetalBar boundaryConditionClamped];
        _rightBoundaryCondition = [AKStruckMetalBar boundaryConditionClamped];
        _scanSpeed = akp(0.23);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSmallHollowMetalBar
{
    return [[AKStruckMetalBar alloc] initWithPresetSmallHollowMetalBar];
}

- (instancetype)initWithPresetSmallTinklingMetalBar
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _decayTime = akp(0.1);
        _dimensionlessStiffness = akp(900);
        _highFrequencyLoss = akp(0.1);
        _strikePosition = akp(0.2);
        _strikeVelocity = akp(5000);
        _strikeWidth = akp(0.9);
        _leftBoundaryCondition  = [AKStruckMetalBar boundaryConditionClamped];
        _rightBoundaryCondition = [AKStruckMetalBar boundaryConditionClamped];
        _scanSpeed = akp(0.23);
        [self setUpConnections];
    }
    return self;
}

+ (instancetype)presetSmallTinklingMetalBar
{
    return [[AKStruckMetalBar alloc] initWithPresetSmallTinklingMetalBar];
}

- (void)setDecayTime:(AKConstant *)decayTime {
    _decayTime = decayTime;
    [self setUpConnections];
}

- (void)setOptionalDecayTime:(AKConstant *)decayTime {
    [self setDecayTime:decayTime];
}

- (void)setDimensionlessStiffness:(AKConstant *)dimensionlessStiffness {
    _dimensionlessStiffness = dimensionlessStiffness;
    [self setUpConnections];
}

- (void)setOptionalDimensionlessStiffness:(AKConstant *)dimensionlessStiffness {
    [self setDimensionlessStiffness:dimensionlessStiffness];
}

- (void)setHighFrequencyLoss:(AKConstant *)highFrequencyLoss {
    _highFrequencyLoss = highFrequencyLoss;
    [self setUpConnections];
}

- (void)setOptionalHighFrequencyLoss:(AKConstant *)highFrequencyLoss {
    [self setHighFrequencyLoss:highFrequencyLoss];
}

- (void)setStrikePosition:(AKConstant *)strikePosition {
    _strikePosition = strikePosition;
    [self setUpConnections];
}

- (void)setOptionalStrikePosition:(AKConstant *)strikePosition {
    [self setStrikePosition:strikePosition];
}

- (void)setStrikeVelocity:(AKConstant *)strikeVelocity {
    _strikeVelocity = strikeVelocity;
    [self setUpConnections];
}

- (void)setOptionalStrikeVelocity:(AKConstant *)strikeVelocity {
    [self setStrikeVelocity:strikeVelocity];
}

- (void)setStrikeWidth:(AKConstant *)strikeWidth {
    _strikeWidth = strikeWidth;
    [self setUpConnections];
}

- (void)setOptionalStrikeWidth:(AKConstant *)strikeWidth {
    [self setStrikeWidth:strikeWidth];
}

- (void)setLeftBoundaryCondition:(AKConstant *)leftBoundaryCondition {
    _leftBoundaryCondition = leftBoundaryCondition;
    [self setUpConnections];
}

- (void)setOptionalLeftBoundaryCondition:(AKConstant *)leftBoundaryCondition {
    [self setLeftBoundaryCondition:leftBoundaryCondition];
}

- (void)setRightBoundaryCondition:(AKConstant *)rightBoundaryCondition {
    _rightBoundaryCondition = rightBoundaryCondition;
    [self setUpConnections];
}

- (void)setOptionalRightBoundaryCondition:(AKConstant *)rightBoundaryCondition {
    [self setRightBoundaryCondition:rightBoundaryCondition];
}

- (void)setScanSpeed:(AKParameter *)scanSpeed {
    _scanSpeed = scanSpeed;
    [self setUpConnections];
}

- (void)setOptionalScanSpeed:(AKParameter *)scanSpeed {
    [self setScanSpeed:scanSpeed];
}


- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[_decayTime, _dimensionlessStiffness, _highFrequencyLoss, _strikePosition, _strikeVelocity, _strikeWidth, _leftBoundaryCondition, _rightBoundaryCondition, _scanSpeed];
}

- (NSString *)inlineStringForCSD
{
    NSMutableString *inlineCSDString = [[NSMutableString alloc] init];

    [inlineCSDString appendString:@"barmodel("];
    [inlineCSDString appendString:[self inputsString]];
    [inlineCSDString appendString:@")"];

    return inlineCSDString;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ barmodel ", self];
    [csdString appendString:[self inputsString]];
    return csdString;
}

- (NSString *)inputsString {
    NSMutableString *inputsString = [[NSMutableString alloc] init];

    
    [inputsString appendFormat:@"%@, ", _leftBoundaryCondition];
    
    [inputsString appendFormat:@"%@, ", _rightBoundaryCondition];
    
    [inputsString appendFormat:@"%@, ", _dimensionlessStiffness];
    
    [inputsString appendFormat:@"%@, ", _highFrequencyLoss];
    
    if ([_scanSpeed class] == [AKControl class]) {
        [inputsString appendFormat:@"%@, ", _scanSpeed];
    } else {
        [inputsString appendFormat:@"AKControl(%@), ", _scanSpeed];
    }

    [inputsString appendFormat:@"%@, ", _decayTime];
    
    [inputsString appendFormat:@"%@, ", _strikePosition];
    
    [inputsString appendFormat:@"%@, ", _strikeVelocity];
    
    [inputsString appendFormat:@"%@", _strikeWidth];
    return inputsString;
}

@end
