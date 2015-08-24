//
//  DistortionMicrophonePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/17/15. (But it feels like Halloween!)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Distortion : AKInstrument
@property AKInstrumentProperty *pregain;
@property AKInstrumentProperty *postgain;
@property AKInstrumentProperty *positiveShapeParameter;
@property AKInstrumentProperty *negativeShapeParameter;
@property AKInstrumentProperty *mix;
@end

@implementation Distortion

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super initWithNumber:2];
    if (self) {

        _pregain  = [self createPropertyWithValue:1 minimum:0 maximum:5.0];
        _postgain = [self createPropertyWithValue:1 minimum:0 maximum:5.0];
        _positiveShapeParameter = [self createPropertyWithValue:0 minimum:0 maximum:1];
        _negativeShapeParameter = [self createPropertyWithValue:0 minimum:0 maximum:1];
        _mix = [self createPropertyWithValue:1 minimum:0 maximum:1];

        AKDistortion *distortion = [[AKDistortion alloc] initWithInput:input
                                                               pregain:_pregain
                                                 postiveShapeParameter:_positiveShapeParameter
                                                negativeShapeParameter:_negativeShapeParameter
                                                              postgain:_postgain];
        AKMix *mix  = [[AKMix alloc] initWithInput1:input input2:distortion balance:_mix];
        [self setAudioOutput:mix];
        [self resetParameter:input];
    }
    return self;
}

@end

@implementation Playground

- (void)run
{
    [super run];

    AKMicrophone *mic = [[AKMicrophone alloc] initWithNumber:1];
    [AKOrchestra addInstrument:mic];
    [mic restart];

    Distortion *distortion = [[Distortion alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:distortion];
    [distortion restart];

    [self addSliderForProperty:distortion.pregain title:@"Pre-gain"];
    [self addSliderForProperty:distortion.positiveShapeParameter title:@"Positive Shape Param"];
    [self addSliderForProperty:distortion.negativeShapeParameter title:@"Negative Shape Param"];
    [self addSliderForProperty:distortion.postgain title:@"Post-gain"];
    [self addSliderForProperty:distortion.mix title:@"Mix"];

}

@end
