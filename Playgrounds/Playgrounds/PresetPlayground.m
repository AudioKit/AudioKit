//
//  PresetPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

// The playground is here for development of custom presets

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKInstrument *defaultInstrument = [AKInstrument instrumentWithNumber:1];
    AKInstrument *testInstrument    = [AKInstrument instrumentWithNumber:2];
    AKInstrument *presetInstrument  = [AKInstrument instrumentWithNumber:3];

    // Here we just instantiate the current sensible default
    AKTambourine *defaultTambourine = [AKTambourine tambourine];
    [defaultInstrument setAudioOutput:defaultTambourine];

    // Here we instead create a new instrument based on default but with new parameters
    AKTambourine *testTambourine = [AKTambourine tambourine];
    testTambourine.dampingFactor = akp(0.6);
    [testInstrument setAudioOutput:testTambourine];

    // Once you create the preset, you can use it here to make sure it sounds the same as the presetInstrument
//    AKTambourine *presetTambourine = [AKTambourine presetSomethingTambourine];
//    [presetInstrument setAudioOutput:presetInstrument];

    [AKOrchestra addInstrument:defaultInstrument];
    [AKOrchestra addInstrument:presetInstrument];
    [AKOrchestra addInstrument:testInstrument];

    AKNote *note = [[AKNote alloc] init];
    note.duration = akp(2.0);
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];

    // As you are changing the testInstrument, you probably want to hear it
    // This will play the phrase once for each save
    [testInstrument playPhrase:phrase];

    [self addButtonWithTitle:@"Play Default" block:^{
        [defaultInstrument playPhrase:phrase];
    }];
    [self addButtonWithTitle:@"Play Test" block:^{
        [testInstrument playPhrase:phrase];
    }];
    [self addButtonWithTitle:@"Play Preset" block:^{
        [presetInstrument playPhrase:phrase];
    }];

    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];

}

@end
