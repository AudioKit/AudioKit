//
//  SignalModifierPresetsPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/7/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

// The playground is here for development of custom presets

#import "Playground.h"

@implementation Playground {
    AKInstrument *presetInstrument;
}

- (AKAudio *)mono
{
    NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
    AKFileInput *presetStereo = [[AKFileInput alloc] initWithFilename:filename];
    presetStereo.loop = YES;
    AKMix *presetAudio = [[AKMix alloc] initMonoAudioFromStereoInput:presetStereo];
    return presetAudio;
}

- (void)playPresetOperation:(AKAudio *)presetOperation forDuration:(float)duration
{
    presetInstrument  = [AKInstrument instrumentWithNumber:1];
    [presetInstrument setAudioOutput:presetOperation];
    [AKOrchestra addInstrument:presetInstrument];
    [presetInstrument playForDuration:duration];
}

- (void)playPresetStereoOperation:(AKStereoAudio *)presetOperation forDuration:(float)duration
{
    presetInstrument  = [AKInstrument instrumentWithNumber:1];
    [presetInstrument setStereoAudioOutput:presetOperation];
    [AKOrchestra addInstrument:presetInstrument];
    [presetInstrument playForDuration:duration];
}

- (void)run
{
    [super run];

    [self makeSection:@"Reverb"];
    [self addButtonWithTitle:@"LargeHallReverb" block:^{
        [self playPresetStereoOperation:[AKReverb presetLargeHallReverbWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"MuffledCanReverb" block:^{
        [self playPresetStereoOperation:[AKReverb presetMuffledCanReverbWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Flat Freq Resp Reverb"];
    [self addButtonWithTitle:@"MetallicReverb" block:^{
        [self playPresetOperation:[AKFlatFrequencyResponseReverb presetMetallicReverbWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"StutteringReverb" block:^{
        [self playPresetOperation:[AKFlatFrequencyResponseReverb presetStutteringReverbWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Delay"];
    [self addButtonWithTitle:@"ChoppedDelay" block:^{
        [self playPresetOperation:[AKDelay presetChoppedDelayWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"ShortAttackDelay" block:^{
        [self playPresetOperation:[AKDelay presetShortAttackDelayWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"RhythmicAttackDelay" block:^{
        [self playPresetOperation:[AKDelay presetRhythmicAttackDelayWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Comb Filter"];
    [self addButtonWithTitle:@"ShuffleFilter" block:^{
        [self playPresetOperation:[AKCombFilter presetShuffleFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"SpringFilter" block:^{
        [self playPresetOperation:[AKCombFilter presetSpringFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Moog Ladder"];
    [self addButtonWithTitle:@"BassHeavyFilter" block:^{
        [self playPresetOperation:[AKMoogLadder presetBassHeavyFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"UnderwaterFilter" block:^{
        [self playPresetOperation:[AKMoogLadder presetUnderwaterFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Moog VCF"];
    [self addButtonWithTitle:@"HighTrebleFilter" block:^{
        [self playPresetOperation:[AKMoogVCF presetHighTrebleFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"FoggyBottomFilter" block:^{
        [self playPresetOperation:[AKMoogVCF presetFoggyBottomFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"String Resonator"];
    [self addButtonWithTitle:@"MachineResonator" block:^{
        [self playPresetOperation:[AKStringResonator presetMachineResonatorWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Low Pass Filter"];
    [self addButtonWithTitle:@"MuffledFilter" block:^{
        [self playPresetOperation:[AKLowPassFilter presetMuffledFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"High Pass Filter"];
    [self addButtonWithTitle:@"HighCutoffFilter" block:^{
        [self playPresetOperation:[AKHighPassFilter presetHighCutoffFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Decimator"];
    [self addButtonWithTitle:@"CrunchyDecimator" block:^{
        [self playPresetOperation:[AKDecimator presetCrunchyDecimatorWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"VideogameDecimator" block:^{
        [self playPresetOperation:[AKDecimator presetVideogameDecimatorWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"RobotDecimator" block:^{
        [self playPresetOperation:[AKDecimator presetRobotDecimatorWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Band Pass Butterworth"];
    [self addButtonWithTitle:@"TrebleHeavyFilter" block:^{
        [self playPresetOperation:[AKBandPassButterworthFilter presetTrebleHeavyFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Band Reject Butterworth"];
    [self addButtonWithTitle:@"BassRejectFilter" block:^{
        [self playPresetOperation:[AKBandRejectButterworthFilter presetBassRejectFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"TrebleRejectFilter" block:^{
        [self playPresetOperation:[AKBandRejectButterworthFilter presetTrebleRejectFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"High Pass Butterworth"];
    [self addButtonWithTitle:@"ExtremeFilter" block:^{
        [self playPresetOperation:[AKHighPassButterworthFilter presetExtremeFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"ModerateFilter" block:^{
        [self playPresetOperation:[AKHighPassButterworthFilter presetModerateFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Low Pass Butterworth"];
    [self addButtonWithTitle:@"BassHeavyFilter" block:^{
        [self playPresetOperation:[AKLowPassButterworthFilter presetBassHeavyFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"MildBassFilter" block:^{
        [self playPresetOperation:[AKLowPassButterworthFilter presetMildBassFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Equalizer Filter"];
    [self addButtonWithTitle:@"NarrowHighFrequencyNotchFilter" block:^{
        [self playPresetOperation:[AKEqualizerFilter presetNarrowHighFrequencyNotchFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"NarrowLowFrequencyNotchFilter" block:^{
        [self playPresetOperation:[AKEqualizerFilter presetNarrowLowFrequencyNotchFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"WideHighFrequencyNotchFilter" block:^{
        [self playPresetOperation:[AKEqualizerFilter presetWideHighFrequencyNotchFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"WideLowFrequencyNotchFilter" block:^{
        [self playPresetOperation:[AKEqualizerFilter presetWideLowFrequencyNotchFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Variable Freq Resp Band Pass"];
    [self addButtonWithTitle:@"MuffledFilter" block:^{
        [self playPresetOperation:[AKVariableFrequencyResponseBandPassFilter presetMuffledFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"LargeMuffledFilter" block:^{
        [self playPresetOperation:[AKVariableFrequencyResponseBandPassFilter presetLargeMuffledFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"TreblePeakFilter" block:^{
        [self playPresetOperation:[AKVariableFrequencyResponseBandPassFilter presetTreblePeakFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"BassPeakFilter" block:^{
        [self playPresetOperation:[AKVariableFrequencyResponseBandPassFilter presetBassPeakFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Hilbert Transformer"];
    [self addButtonWithTitle:@"AlienSpaceshipFilter" block:^{
        [self playPresetOperation:[AKHilbertTransformer presetAlienSpaceshipFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"MosquitoFilter" block:^{
        [self playPresetOperation:[AKHilbertTransformer presetMosquitoFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"3 Pole Low Pass"];
    [self addButtonWithTitle:@"BrightFilter" block:^{
        [self playPresetOperation:[AKThreePoleLowpassFilter presetBrightFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"DullBass" block:^{
        [self playPresetOperation:[AKThreePoleLowpassFilter presetDullBassWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Scream" block:^{
        [self playPresetOperation:[AKThreePoleLowpassFilter presetScreamWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Ball in a Box"];
    [self addButtonWithTitle:@"StutteringReverb" block:^{
        [self playPresetStereoOperation:[AKBallWithinTheBoxReverb presetStutteringReverbWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"PloddingReverb" block:^{
        [self playPresetStereoOperation:[AKBallWithinTheBoxReverb presetPloddingReverbWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Resonant Filter"];
    [self addButtonWithTitle:@"MuffledFilter" block:^{
        [self playPresetOperation:[AKResonantFilter presetMuffledFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"HighTrebleFilter" block:^{
        [self playPresetOperation:[AKResonantFilter presetHighTrebleFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"HighBassFilter" block:^{
        [self playPresetOperation:[AKResonantFilter presetHighBassFilterWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];

    [self makeSection:@"Panner"];
    [self addButtonWithTitle:@"HardLeft" block:^{
        [self playPresetOperation:[AKPanner presetDefaultHardLeftWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Centered" block:^{
        [self playPresetOperation:[AKPanner presetDefaultCenteredWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"HardRight" block:^{
        [self playPresetOperation:[AKPanner presetDefaultHardRighWithInput:[self mono]] forDuration:10.0];
    }];
    [self addButtonWithTitle:@"Stop" block:^{[presetInstrument stop];}];


}

@end
