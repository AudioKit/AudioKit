//
//  StruckMetalBar.m
//  AudioKitPlayground
//
//  Created by Nicholas Arner on 3/21/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "StruckMetalBar.h"

@implementation StruckMetalBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Note Properties
        StruckMetalBarNote *note = [[StruckMetalBarNote alloc] init];

        // Instrument Properties
        _amplitude = [self createPropertyWithValue:1.0 minimum:0.0 maximum:1.0];

        // Instrument Definition
        AKStruckMetalBar *struckMetalBar = [AKStruckMetalBar strike];
        struckMetalBar.decayTime = note.decayTime;
        struckMetalBar.dimensionlessStiffness = note.dimensionlessStiffness;
        struckMetalBar.highFrequencyLoss = note.highFrequencyLoss;
        struckMetalBar.strikePosition = note.strikePosition;
        struckMetalBar.strikeVelocity = note.strikeVelocity;
        struckMetalBar.strikeWidth = note.strikeWidth;
//        struckMetalBar.leftBoundaryCondition = note.leftBoundaryCondition;
//        struckMetalBar.rightBoundaryCondition = note.rightBoundaryCondition;
//        struckMetalBar.scanSpeed = note.scanSpeed;


        [self setAudioOutput:[struckMetalBar scaledBy:_amplitude]];

        // Output to global effects processing (choose mono or stereo accordingly)
        _auxilliaryOutput = [AKAudio globalParameter];
        //_auxilliaryOutput = [AKStereoAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:struckMetalBar];
    }
    return self;
}
@end

// -----------------------------------------------------------------------------
#  pragma mark - StruckMetalBar Note
// -----------------------------------------------------------------------------


@implementation StruckMetalBarNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _decayTime = [self createPropertyWithValue:2 minimum:1 maximum:20];
        _dimensionlessStiffness = [self createPropertyWithValue:100 minimum:1 maximum:500];
        _highFrequencyLoss = [self createPropertyWithValue:0.001 minimum:0 maximum:0.005];
        _strikePosition = [self createPropertyWithValue:0.2 minimum:0 maximum:0.9];
        _strikeVelocity = [self createPropertyWithValue:800 minimum:100 maximum:1000];
        _strikeWidth = [self createPropertyWithValue:0.2 minimum:0 maximum:0.9];

        // Optionally set a default note duration
        self.duration.value = 1.0;
    }
    return self;
}



@end
