//
//  StruckMetalBar.m
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStruckMetalBarInstrument.h"

@implementation AKStruckMetalBarInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        AKStruckMetalBarNote *note = [[AKStruckMetalBarNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKStruckMetalBar *struckMetalBar = [AKStruckMetalBar strike];
        struckMetalBar.decayTime              = note.decayTime;
        struckMetalBar.dimensionlessStiffness = note.dimensionlessStiffness;
        struckMetalBar.highFrequencyLoss      = note.highFrequencyLoss;
        struckMetalBar.strikePosition         = note.strikePosition;
        struckMetalBar.strikeVelocity         = note.strikeVelocity;
        struckMetalBar.strikeWidth            = note.strikeWidth;
        struckMetalBar.scanSpeed              = note.scanSpeed;
        struckMetalBar.leftBoundaryCondition  = note.leftBoundaryCondition;
        struckMetalBar.rightBoundaryCondition = note.rightBoundaryCondition;

        _output = [AKAudio globalParameter];
        [self assignOutput:_output to:[struckMetalBar scaledBy:_amplitude]];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - StruckMetalBar Note
// -----------------------------------------------------------------------------

@implementation AKStruckMetalBarNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _decayTime = [self createPropertyWithValue:2 minimum:1 maximum:20];
        _decayTime.isContinuous = NO;
        _dimensionlessStiffness = [self createPropertyWithValue:100 minimum:1 maximum:500];
        _dimensionlessStiffness.isContinuous = NO;
        _highFrequencyLoss = [self createPropertyWithValue:0.001 minimum:0 maximum:0.005];
        _highFrequencyLoss.isContinuous = NO;
        _strikePosition = [self createPropertyWithValue:0.2 minimum:0 maximum:0.9];
        _strikePosition.isContinuous = NO;
        _strikeVelocity = [self createPropertyWithValue:800 minimum:100 maximum:1000];
        _strikeVelocity.isContinuous = NO;
        _strikeWidth = [self createPropertyWithValue:0.2 minimum:0 maximum:0.9];
        _strikeWidth.isContinuous = NO;
        _scanSpeed = [self createPropertyWithValue:0.23 minimum:0 maximum:0.9];
        _scanSpeed.isContinuous = NO;
        _leftBoundaryCondition  = [self createPropertyWithValue:0 minimum:0 maximum:2];
        _rightBoundaryCondition = [self createPropertyWithValue:0 minimum:0 maximum:2];

        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}



@end
