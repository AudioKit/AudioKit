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
    //    AKReverb *presetOperation = [AKReverb presetSmallHallReverbWithInput:presetAudio];
    //    AKReverb *presetOperation = [AKReverb presetLargeHallReverbWithInput:presetAudio];
    //    AKReverb *presetOperation = [AKReverb presetMuffledCanReverbWithInput:presetAudio];
    //
    //    AKFlatFrequencyResponseReverb *presetOperation = [AKFlatFrequencyResponseReverb presetMetallicReverbWithInput:presetAudio];
    //    AKFlatFrequencyResponseReverb *presetOperation = [AKFlatFrequencyResponseReverb presetStutteringReverbWithInput:presetAudio];
    //
    //    AKDelay *presetOperation = [AKDelay presetChoppedDelayWithInput:presetAudio];
    //    AKDelay *presetOperation = [AKDelay presetShortAttackDelayWithInput:presetAudio];
    //    AKDelay *presetOperation = [AKDelay presetRhythmicDelayWithInput:presetAudio];
    //
    //    AKCombFilter *presetOperation = [AKCombFilter presetShufflingFilterWithInput:presetAudio];
    //    AKCombFilter *presetOperation = [AKCombFilter presetSpringyFilterWithInput:presetAudio];
    //
    //
    //    AKMoogLadder *presetOperation = [AKMoogLadder presetBassHeavyFilterWithInput:presetAudio];
    //    AKMoogLadder *presetOperation = [AKMoogLadder presetUnderwaterFilterWithInput:presetAudio];
    
    ///// May 25th
    //    AKMoogVCF *presetOperation = [AKMoogVCF presetHighTrebleFilterWithInput:presetAudio];
    //    AKMoogVCF *presetOperation = [AKMoogVCF presetFoggyBottomFilterWithInput:presetAudio];
    //
    //    AKStringResonator *presetOperation = [AKStringResonator presetMachineResonatorWithInput:presetAudio];
    //
    //    AKLowPassFilter *presetOperation = [AKLowPassFilter presetMuffledFilterWithInput:presetAudio];
    //
    //    AKHighPassFilter *presetOperation = [AKHighPassFilter presetHighCutoffFilterWithInput:presetAudio];
    //
    //    AKDecimator *presetOperation = [AKDecimator presetCrunchyDecimatorWithInput:presetAudio];
    //    AKDecimator *presetOperation = [AKDecimator presetVideogameDecimatorWithInput:presetAudio];
    //    AKDecimator *presetOperation = [AKDecimator presetRobotDecimatorWithInput:presetAudio];
    //
    //    AKBandPassButterworthFilter *presetOperation = [AKBandPassButterworthFilter presetTrebleHeavyFilterWithInput:presetAudio];
    //
    //    AKBandRejectButterworthFilter *presetOperation = [AKBandRejectButterworthFilter presetBassRejectFilterWithInput:presetAudio];
    //    AKBandRejectButterworthFilter *presetOperation = [AKBandRejectButterworthFilter presetTrebleRejectFilterWithInput:presetAudio];
    //
    //    AKVibes *presetOperation = [AKVibes presetRingingVibes];
    //
    //    AKHighPassButterworthFilter *presetOperation = [AKHighPassButterworthFilter presetExtremeFilterWithInput:presetAudio];
    //    AKHighPassButterworthFilter *presetOperation = [AKHighPassButterworthFilter alloc] initWithModerateFilterWithInput:presetAudio];
    //
    //    AKLowPassButterworthFilter *presetOperation = [AKLowPassButterworthFilter presetBassHeavyFilterWithInput:presetAudio];
    //    AKLowPassButterworthFilter *presetOperation = [AKLowPassButterworthFilter presetMildBassFilterWithInput:presetAudio];
    
    ///// May 26th
    //    AKEqualizerFilter *presetOperation = [AKEqualizerFilter presetNarrowHighFrequencyNotchFilterWithInput:presetAudio];
    //    AKEqualizerFilter *presetOperation = [AKEqualizerFilter presetNarrowLowFrequencyNotchFilterWithInput:presetAudio];
    //    AKEqualizerFilter *presetOperation = [AKEqualizerFilter presetWideHighFrequencyNotchFilterWithInput:presetAudio];
    // AKEqualizerFilter *presetOperation = [AKEqualizerFilter presetWideLowFrequencyNotchFilterWithInput:presetAudio];
    
    
    ///// May 27th
    //    AKVariableFrequencyResponseBandPassFilter *presetOperation = [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetMuffledFilterWithInput:presetAudio];
    
    //    AKVariableFrequencyResponseBandPassFilter *presetOperation = [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetLargeMuffledFilterWithInput:presetAudio];
    
    //    AKVariableFrequencyResponseBandPassFilter *presetOperation = [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetTreblePeakFilterWithInput:presetAudio];
    
    //    AKVariableFrequencyResponseBandPassFilter *presetOperation = [[AKVariableFrequencyResponseBandPassFilter alloc] initWithPresetBassPeakFilterWithInput:presetAudio];
    
    
    
    ///// May 30th
//        AKHilbertTransformer *presetOperation = [[AKHilbertTransformer alloc] initWithPresetAlienSpaceshipWithInput:presetAudio];
//        AKHilbertTransformer *presetOperation = [[AKHilbertTransformer alloc] initWithPresetMosquitoWithInput:presetAudio];
//        AKThreePoleLowpassFilter *presetOperation = [[AKThreePoleLowpassFilter alloc] initWithPresetBrightFilterWithInput:presetAudio];
//        AKThreePoleLowpassFilter *presetOperation = [[AKThreePoleLowpassFilter alloc] initWithPresetDullBassWithInput:presetAudio];
//        AKThreePoleLowpassFilter *presetOperation = [[AKThreePoleLowpassFilter alloc] initWithPresetScreamWithInput:presetAudio];
    
//        AKBallWithinTheBoxReverb *presetOperation = [[AKBallWithinTheBoxReverb alloc] initWithPresetStutteringReverbWithInput:presetAudio];
//        AKBallWithinTheBoxReverb *presetOperation = [[AKBallWithinTheBoxReverb alloc] initWithPresetPloddingReverbWithInput:presetAudio];
    
    
    ///// May 31st
   AKResonantFilter *presetOperation = [[AKResonantFilter alloc] initWithPresetMuffledFilterWithInput:presetAudio];
//    AKResonantFilter *presetOperation = [[AKResonantFilter alloc] initWithPresetHighTrebleFilterWithInput:presetAudio];
    // AKResonantFilter *presetOperation = [[AKResonantFilter alloc] initWithPresetHighBassFilterWithInput:presetAudio];

    
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
