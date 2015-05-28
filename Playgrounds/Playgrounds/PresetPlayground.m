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
    AKFileInput *defaultInstrumentSourceStereoAudio = [[AKFileInput alloc] initWithFilename:filename];
    defaultInstrumentSourceStereoAudio.loop = YES;
    AKFileInput *testInstrumentSourceStereoAudio = [[AKFileInput alloc] initWithFilename:filename];
    testInstrumentSourceStereoAudio.loop = YES;
    AKFileInput *presetInstrumentSourceStereoAudio = [[AKFileInput alloc] initWithFilename:filename];
    presetInstrumentSourceStereoAudio.loop = YES;

    AKMix *defaultInstrumentSourceAudio = [[AKMix alloc] initMonoAudioFromStereoInput:defaultInstrumentSourceStereoAudio];
    AKMix *testInstrumentSourceAudio = [[AKMix alloc] initMonoAudioFromStereoInput:testInstrumentSourceStereoAudio];
    AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:presetInstrumentSourceStereoAudio];

    AKInstrument *defaultInstrument = [AKInstrument instrumentWithNumber:1];
    AKInstrument *testInstrument    = [AKInstrument instrumentWithNumber:2];
    AKInstrument *presetInstrument  = [AKInstrument instrumentWithNumber:3];

    // Here we just instantiate the current sensible default
    AKBandPassButterworthFilter *defaultOperation = [[AKBandPassButterworthFilter alloc] initWithInput:defaultInstrumentSourceAudio];
    [defaultInstrument setAudioOutput:defaultOperation];

    // Here we instead create a new instrument based on default but with new parameters
    //  GENERATOR TEMPLATE
    //    AKTambourine *testOperation = [AKTambourine tambourine];
    //    testOperation.dampingFactor = akp(0.6);
    //    [testInstrument setAudioOutput:testOperation];

    //  MODIFIER TEMPLATE
    AKBandPassButterworthFilter *testOperation = [[AKBandPassButterworthFilter alloc] initWithInput:testInstrumentSourceAudio];
    [testInstrument setAudioOutput:testOperation];

    // Once you create the preset, you can use it here to make sure it sounds the same as the presetInstrument
    //    AKBambooSticks *presetOperation = [AKBambooSticks presetDefaultSticks];
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

    ///// May 17th
    //    AKMandolin *presetOperation = [AKMandolin presetDetunedMandolin];
    //    AKMandolin *presetOperation = [AKMandolin presetSmallMandolin];
    //    AKFMOscillator *presetOperation = [AKFMOscillator presetStunRay];
    //    AKFMOscillator *presetOperation = [AKFMOscillator presetWobble];
    //    AKFMOscillator *presetOperation = [AKFMOscillator presetFogHorn];
    //    AKFMOscillator *presetOperation = [AKFMOscillator presetSpaceWobble];
    //    AKFMOscillator *presetOperation = [AKFMOscillator presetBuzzer];
    //    AKVCOscillator *presetOperation = [AKVCOscillator presetSquareOscillator];
    //    AKVCOscillator *presetOperation = [AKVCOscillator presetTriangleOscillator];
    //    AKVCOscillator *presetOperation = [AKVCOscillator presetSawtoothOscillator];
    //    AKVCOscillator *presetOperation = [AKVCOscillator presetSquareWithPWMOscillator];
    //    AKVCOscillator *presetOperation = [AKVCOscillator presetUnnormalizedPulseOscillator];
    //    AKVCOscillator *presetOperation = [AKVCOscillator presetIntegratedSawtoothOscillator];


    ///// May 20th
    //     AKMarimba *presetOperation = [AKMarimba presetDryMutedMarimba];
    //     AKMarimba *presetOperation = [AKMarimba presetGentleMarimba];
    //     AKMarimba *presetOperation = [AKMarimba presetLooseMarimba];
    //     AKPluckedString *presetOperation = [AKPluckedString presetDecayingPluckedString];
    //     AKPluckedString *presetOperation = [AKPluckedString presetRoundedPluckedString];
    //     AKPluckedString *presetOperation = [AKPluckedString presetSnappyPluckedString];

    ///// May 21st
    //     AKStruckMetalBar *presetOperation = [AKStruckMetalBar presetThickDullMetalBar];
    //     AKStruckMetalBar *presetOperation = [AKStruckMetalBar presetIntenseDecayingMetalBar];
    //     AKStruckMetalBar *presetOperation = [AKStruckMetalBar presetSmallHollowMetalBar];
    //     AKStruckMetalBar *presetOperation = [AKStruckMetalBar presetSmallTinklingMetalBar];

    //     AKVibes *presetOperation = [AKVibes presetTinyVibes];
    //     AKVibes *presetOperation = [AKVibes presetGentleVibes];

    //     AKBowedString *presetOperation = [AKBowedString presetWhistlingBowedString];
    //     AKBowedString *presetOperation = [AKBowedString presetTrainWhislteBowedString];
    //     AKBowedString *presetOperation = [AKBowedString presetCelloBowedString];
    //     AKBowedString *presetOperation = [AKBowedString presetFeedbackBowedString];
    //     AKBowedString *presetOperation = [AKBowedString presetFogHornBowedString];

    ///// May 22nd
    //    AKFlute *presetOperation = [AKFlute presetMicFeedbackFlute];
    //    AKFlute *presetOperation = [AKFlute presetShipsHornFlute];
    //    AKFlute *presetOperation = [AKFlute presetSciFiNoiseFlute];
    //    AKFlute *presetOperation = [AKFlute presetScreamingFlute];


    ///// May 24th
    //    AKReverb *presetOperation = [AKReverb presetSmallHallReverbWithInput:mono];
    //    AKReverb *presetOperation = [AKReverb presetLargeHallReverbWithInput:mono];
    //    AKReverb *presetOperation = [AKReverb presetMuffledCanReverbWithInput:mono];
    //
    //    AKFlatFrequencyResponseReverb *presetOperation = [AKFlatFrequencyResponseReverb presetMetallicReverbWithInput:mono];
    //    AKFlatFrequencyResponseReverb *presetOperation = [AKFlatFrequencyResponseReverb presetStutteringReverbWithInput:mono];
    //
    //    AKDelay *presetOperation = [AKDelay presetChoppedDelayWithInput:mono];
    //    AKDelay *presetOperation = [AKDelay presetShortAttackDelayWithInput:mono];
    //    AKDelay *presetOperation = [AKDelay presetRhythmicDelayWithInput:mono];
    //
    //    AKCombFilter *presetOperation = [AKCombFilter presetShufflingFilterWithInput:mono];
    //    AKCombFilter *presetOperation = [AKCombFilter presetSpringyFilterWithInput:mono];
    //
    //
    //    AKMoogLadder *presetOperation = [AKMoogLadder presetBassHeavyFilterWithInput:mono];
    //    AKMoogLadder *presetOperation = [AKMoogLadder presetUnderwaterFilterWithInput:mono];

    ///// May 25th
    // AKMoogVCF *presetOperation = [[AKMoogVCF alloc] initWithPresetHighTrebleFilterWithInput:mono3];
    // AKMoogVCF *presetOperation = [[AKMoogVCF alloc] initWithPresetFoggyBottomFilterWithInput:mono3];
    
    // AKStringResonator *presetOperation = [[AKStringResonator alloc] initWithPresetMachineResonatorWithInput:mono3];
    
    // AKLowPassFilter *presetOperation = [[AKLowPassFilter alloc] initWithPresetMuffledFilterWithInput:mono3];
    
    // AKHighPassFilter *presetOperation = [[AKHighPassFilter alloc] initWithPresetHighCutoffFilterWithInput:mono3];
    
    // AKDecimator *presetOperation = [[AKDecimator alloc] initWithPresetCrunchyDecimatorWithInput:mono3];
    // AKDecimator *presetOperation = [[AKDecimator alloc] initWithPresetVideogameDecimatorWithInput:mono3];
    // AKDecimator *presetOperation = [[AKDecimator alloc] initWithPresetRobotDecimatorWithInput:mono3];
    
    // AKBandPassButterworthFilter *defaultOperation = [[AKBandPassButterworthFilter alloc] initWithPresetBassHeavyFilterWithInput:mono1];
    // AKBandPassButterworthFilter *presetOperation = [[AKBandPassButterworthFilter alloc] initWithPresetTrebleHeavyFilterWithInput:mono3];
    
    // AKBandRejectButterworthFilter *presetOperation = [[AKBandRejectButterworthFilter alloc] initWithPresetBassRejectFilterWithInput:mono3];
    // AKBandRejectButterworthFilter *presetOperation = [[AKBandRejectButterworthFilter alloc] initWithPresetTrebleRejectFilterWithInput:mono3];
    
    // AKVibes *presetOperation = [[AKVibes alloc] initWithPresetRingingVibes];
    
    // AKHighPassButterworthFilter *presetOperation = [[AKHighPassButterworthFilter alloc] initWithPresetExtremeFilterWithInput:mono3];
    // AKHighPassButterworthFilter *presetOperation = [[AKHighPassButterworthFilter alloc] initWithModerateFilterWithInput:mono3];
    
    // AKLowPassButterworthFilter *presetOperation = [[AKLowPassButterworthFilter alloc] initWithPresetBassHeavyFilterWithInput:mono3];
     // AKLowPassButterworthFilter *presetOperation = [[AKLowPassButterworthFilter alloc] initWithPresetMildBassFilterWithInput:mono3];
    

    ///// May 26th

    // AKEqualizerFilter *presetOperation = [[AKEqualizerFilter alloc] initWithPresetNarrowHighHzNotchFilterWithInput:mono3];
    // AKEqualizerFilter *presetOperation = [[AKEqualizerFilter alloc] initWithPresetNarrowLowHzNotchFilterWithInput:mono3];
    // AKEqualizerFilter *presetOperation = [[AKEqualizerFilter alloc] initWithPresetWideHighHzNotchFilterWithInput:mono3];
    // AKEqualizerFilter *presetOperation = [[AKEqualizerFilter alloc] initWithPresetWideLowHzNotchFilterWithInput:mono3];

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
