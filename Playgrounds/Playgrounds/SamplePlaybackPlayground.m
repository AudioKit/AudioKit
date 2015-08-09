//
//  SamplePlaybackPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"


@interface SamplePlayer : AKInstrument

@property (readonly) AKStereoAudio *auxilliaryOutput;

@property AKInstrumentProperty *speed;

@end

@implementation SamplePlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _speed = [self createPropertyWithValue:1.5 minimum:-2 maximum:2];
        NSString *file;

        file = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *fileInput = [[AKFileInput alloc] initWithFilename:file];
        fileInput.speed = _speed;
        [self setAudioOutput:fileInput];

        _auxilliaryOutput = [AKStereoAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:fileInput];
    }
    return self;
}

@end

@implementation Playground

- (void)run
{
    [super run];
    SamplePlayer *player = [[SamplePlayer alloc] initWithNumber:1];
    [AKOrchestra addInstrument:player];

    [self addSliderForProperty:player.speed title:@"speed"];
    [player restart];
    [self addAudioOutputRollingWaveformPlot];
    [self addAudioOutputPlot];
}

@end
