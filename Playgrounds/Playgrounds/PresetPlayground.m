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
    AKTambourine *defaultOperation = [AKTambourine tambourine];
    [defaultInstrument setAudioOutput:defaultOperation];

    // Here we instead create a new instrument based on default but with new parameters
    AKTambourine *testOperation = [AKTambourine tambourine];
    testOperation.dampingFactor = akp(0.6);
    [testInstrument setAudioOutput:testOperation];

    // Once you create the preset, you can use it here to make sure it sounds the same as the presetInstrument
    AKBambooSticks *presetOperation = [AKBambooSticks presetDefaultSticks];
//    AKBambooSticks *presetOperation = [AKBambooSticks presetFewSticks];
//    AKBambooSticks *presetOperation = [AKBambooSticks presetManySticks];
//    AKCabasa *presetOperation = [AKCabasa presetDefaultCabasa];
//    AKCabasa *presetOperation = [AKCabasa presetLooseCabasa];
//    AKCabasa *presetOperation = [AKCabasa presetMutedCabasa];
//    AKCrunch *presetOperation = [AKCrunch presetDefaultCrunch];
//    AKCrunch *presetOperation = [AKCrunch presetThudCrunch];
//    AKCrunch *presetOperation = [AKCrunch presetDistantCrunch];
//    AKGuiro *presetOperation = [AKGuiro presetDefaultGuiro];
//    AKGuiro *presetOperation = [AKGuiro presetSmallGuiro];
//    AKSandPaper *presetOperation = [AKSandPaper presetDefaultSandPaper];
//    AKSandPaper *presetOperation = [AKSandPaper presetMuffledSandPaper];
//    AKSekere *presetOperation = [AKSekere presetDefaultSekere];
//    AKSekere *presetOperation = [AKSekere presetManyBeadsSekere];
//    AKSleighbells *presetOperation = [AKSleighbells presetDefaultSleighbells];
//    AKSleighbells *presetOperation = [AKSleighbells presetOpenBells];
//    AKSleighbells *presetOperation = [AKSleighbells presetSoftBells];
//    AKStick *presetOperation = [AKStick presetDefaultStick];
//    AKStick *presetOperation = [AKStick presetThickStick];
//    AKStick *presetOperation = [AKStick presetBundleOfSticks];
//    AKTambourine *presetOperation = [AKTambourine presetDefaultTambourine];
//    AKTambourine *presetOperation = [AKTambourine presetOpenTambourine];
//    AKTambourine *presetOperation = [AKTambourine presetClosedTambourine];

    
//    AKTambourine *presetOperation = [AKTambourine presetSomethingTambourine];
    [presetInstrument setAudioOutput:presetOperation];

    [AKOrchestra addInstrument:defaultInstrument];
    [AKOrchestra addInstrument:presetInstrument];
    [AKOrchestra addInstrument:testInstrument];

    AKNote *note = [[AKNote alloc] init];
    note.duration.value = 2.0;
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
