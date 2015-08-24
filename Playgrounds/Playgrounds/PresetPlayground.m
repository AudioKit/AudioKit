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
    
    //Set up the source file we want to use for testing
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *defaultStereo = [[AKFileInput alloc] initWithFilename:filename];
    defaultStereo.loop = YES;
    AKFileInput *testStereo = [[AKFileInput alloc] initWithFilename:filename];
    testStereo.loop = YES;
    AKFileInput *presetStereo = [[AKFileInput alloc] initWithFilename:filename];
    presetStereo.loop = YES;
    
    AKMix *defaultAudio = [[AKMix alloc] initMonoAudioFromStereoInput:defaultStereo];
    AKMix *testAudio    = [[AKMix alloc] initMonoAudioFromStereoInput:testStereo];
    AKMix *presetAudio = [[AKMix alloc] initMonoAudioFromStereoInput:presetStereo];
    
    AKInstrument *defaultInstrument = [AKInstrument instrumentWithNumber:1];
    AKInstrument *testInstrument    = [AKInstrument instrumentWithNumber:2];
    AKInstrument *presetInstrument  = [AKInstrument instrumentWithNumber:3];
    
    // Here we just instantiate the current sensible default
    AKBallWithinTheBoxReverb *defaultOperation = [[AKBallWithinTheBoxReverb alloc] initWithInput:defaultAudio];
    [defaultInstrument setAudioOutput:defaultOperation];
    
    // Here we instead create a new instrument based on default but with new parameters
    //  GENERATOR TEMPLATE
    //    AKTambourine *testOperation = [AKTambourine tambourine];
    //    testOperation.dampingFactor = akp(0.6);
    //    [testInstrument setAudioOutput:testOperation];
    
    //  MODIFIER TEMPLATE
    AKResonantFilter *testOperation = [[AKResonantFilter alloc] initWithInput:testAudio];
    testOperation.centerFrequency = akp(350);
    testOperation.bandwidth = akp(50);
    [testInstrument setAudioOutput:testOperation];
        
    
   AKResonantFilter *presetOperation = [[AKResonantFilter alloc] initWithPresetMuffledFilterWithInput:presetAudio];

    
    [presetInstrument setAudioOutput:presetOperation];
    
    [AKOrchestra addInstrument:defaultInstrument];
    [AKOrchestra addInstrument:testInstrument];
    [AKOrchestra addInstrument:presetInstrument];
    
    AKNote *note = [[AKNote alloc] init];
    note.duration.value = 4.0;
    AKPhrase *phrase = [[AKPhrase alloc] init];
    [phrase addNote:note];
    
    // As you are changing the testInstrument, you probably want to hear it
    // This will play the phrase once for each save
    [presetInstrument playPhrase:phrase];
    
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
