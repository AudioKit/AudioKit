//
//  BinauralAudioPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"


@interface SamplePlayer : AKInstrument

@property (readonly) AKStereoAudio *auxilliaryOutput;

@property AKInstrumentProperty *speed;
@property AKInstrumentProperty *azimuth;
@property AKInstrumentProperty *elevation;

@end

@implementation SamplePlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _speed = [self createPropertyWithValue:1 minimum:-2 maximum:2];
        _azimuth = [self createPropertyWithValue:0 minimum:-180 maximum:180];
        _elevation = [self createPropertyWithValue:0 minimum:-40 maximum:90];
        NSString *file;

        file = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *fileInput = [[AKFileInput alloc] initWithFilename:file];
        fileInput.speed = _speed;
        fileInput.loop = YES;

        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:fileInput];

        AK3DBinauralAudio *binAudio = [[AK3DBinauralAudio alloc] initWithInput:mono
                                                                       azimuth:_azimuth
                                                                     elevation:_elevation];
        [self setStereoAudioOutput:binAudio];
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
    [self addSliderForProperty:player.azimuth title:@"azimuth"];
    [self addSliderForProperty:player.elevation title:@"elevation"];

    [player restart];
    [self addAudioOutputPlot];
}

@end
