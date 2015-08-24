//
//  ClipperPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/17/15. (But it feels like Halloween!)
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Clipper : AKInstrument
@property AKInstrumentProperty *mix;
@end

@implementation Clipper

- (instancetype)initWithInput:(AKAudio *)input
{
    self = [super initWithNumber:2];
    if (self) {

        _mix = [self createPropertyWithValue:0 minimum:0 maximum:1];
        AKClipper *clip = [[AKClipper alloc] initWithInput:input];
        clip.limit = akp(0.2);
        clip.clippingStartPoint = akp(0.1);

        AKMix *mix = [[AKMix alloc] initWithInput1:clip input2:input balance:_mix];
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

    Clipper *clipper = [[Clipper alloc] initWithInput:mic.output];
    [AKOrchestra addInstrument:clipper];
    [clipper restart];

    [self addSliderForProperty:clipper.mix title:@"Mix"];
    [self addAudioInputPlot];
    [self addAudioOutputPlot];

}

@end
