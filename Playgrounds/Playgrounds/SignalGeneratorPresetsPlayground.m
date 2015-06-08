//
//  SignalGeneratorPresetsPlayground.m
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

- (void)playPresetOperation:(AKAudio *)presetOperation forDuration:(float)duration
{
    presetInstrument  = [AKInstrument instrumentWithNumber:1];
    [presetInstrument setAudioOutput:presetOperation];
    [AKOrchestra addInstrument:presetInstrument];
    [presetInstrument playForDuration:duration];
}

- (void)run
{
    [super run];

    [self makeSection:@"FM Oscillator"];
    [self addButtonWithTitle:@"StunRay" block:^{
        [self playPresetOperation:[AKFMOscillator presetStunRay] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"Wobble" block:^{
        [self playPresetOperation:[AKFMOscillator presetWobble] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"FogHorn" block:^{
        [self playPresetOperation:[AKFMOscillator presetFogHorn] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SpaceWobble" block:^{
        [self playPresetOperation:[AKFMOscillator presetSpaceWobble] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"Buzzer" block:^{
        [self playPresetOperation:[AKFMOscillator presetBuzzer] forDuration:3.0];
    }];

    [self makeSection:@"VC Oscillator"];
    [self addButtonWithTitle:@"SquareOscillator" block:^{
        [self playPresetOperation:[AKVCOscillator presetSquareOscillator] forDuration:1.0];
    }];
    [self addButtonWithTitle:@"TriangleOscillator" block:^{
        [self playPresetOperation:[AKVCOscillator presetTriangleOscillator] forDuration:1.0];
    }];
    [self addButtonWithTitle:@"SawtoothOscillator" block:^{
        [self playPresetOperation:[AKVCOscillator presetSawtoothOscillator] forDuration:1.0];
    }];

    [self makeSection:@"Bamboo Sticks"];
    [self addButtonWithTitle:@"DefaultSticks" block:^{
        [self playPresetOperation:[AKBambooSticks presetDefaultSticks] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ManySticks" block:^{
        [self playPresetOperation:[AKBambooSticks presetManySticks] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"FewSticks" block:^{
        [self playPresetOperation:[AKBambooSticks presetFewSticks] forDuration:3.0];
    }];

    [self makeSection:@"Bowed String"];
    [self addButtonWithTitle:@"WhistlingBowedString" block:^{
        [self playPresetOperation:[AKBowedString presetWhistlingBowedString] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"TrainWhislteBowedString" block:^{
        [self playPresetOperation:[AKBowedString presetTrainWhislteBowedString] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"CelloBowedString" block:^{
        [self playPresetOperation:[AKBowedString presetCelloBowedString] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"FeedbackBowedString" block:^{
        [self playPresetOperation:[AKBowedString presetFeedbackBowedString] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"FogHornBowedString" block:^{
        [self playPresetOperation:[AKBowedString presetFogHornBowedString] forDuration:3.0];
    }];

    [self makeSection:@"Cabasa"];
    [self addButtonWithTitle:@"DefaultCabasa" block:^{
        [self playPresetOperation:[AKCabasa presetDefaultCabasa] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"LooseCabasa" block:^{
        [self playPresetOperation:[AKCabasa presetLooseCabasa] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"MutedCabasa" block:^{
        [self playPresetOperation:[AKCabasa presetMutedCabasa] forDuration:3.0];
    }];

    [self makeSection:@"Crunch"];
    [self addButtonWithTitle:@"DefaultCrunch" block:^{
        [self playPresetOperation:[AKCrunch presetDefaultCrunch] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ThudCrunch" block:^{
        [self playPresetOperation:[AKCrunch presetThudCrunch] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"DistantCrunch" block:^{
        [self playPresetOperation:[AKCrunch presetDistantCrunch] forDuration:3.0];
    }];

    [self makeSection:@"Flute"];
    [self addButtonWithTitle:@"MicFeedbackFlute" block:^{
        [self playPresetOperation:[AKFlute presetMicFeedbackFlute] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ShipsHornFlute" block:^{
        [self playPresetOperation:[AKFlute presetShipsHornFlute] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SciFiNoiseFlute" block:^{
        [self playPresetOperation:[AKFlute presetSciFiNoiseFlute] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ScreamingFlute" block:^{
        [self playPresetOperation:[AKFlute presetScreamingFlute] forDuration:3.0];
    }];

    [self makeSection:@"Guiro"];
    [self addButtonWithTitle:@"DefaultGuiro" block:^{
        [self playPresetOperation:[AKGuiro presetDefaultGuiro] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SmallGuiro" block:^{
        [self playPresetOperation:[AKGuiro presetSmallGuiro] forDuration:3.0];
    }];

    [self makeSection:@"Mandolin"];
    [self addButtonWithTitle:@"DetunedMandolin" block:^{
        [self playPresetOperation:[AKMandolin presetDetunedMandolin] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SmallMandolin" block:^{
        [self playPresetOperation:[AKMandolin presetSmallMandolin] forDuration:3.0];
    }];

    [self makeSection:@"Marimba"];
    [self addButtonWithTitle:@"DryMutedMarimba" block:^{
        [self playPresetOperation:[AKMarimba presetDryMutedMarimba] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"GentleMarimba" block:^{
        [self playPresetOperation:[AKMarimba presetGentleMarimba] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"LooseMarimba" block:^{
        [self playPresetOperation:[AKMarimba presetLooseMarimba] forDuration:3.0];
    }];

    [self makeSection:@"Plucked String"];
    [self addButtonWithTitle:@"DecayingPluckedString" block:^{
        [self playPresetOperation:[AKPluckedString presetDecayingPluckedString] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"RoundedPluckedString" block:^{
        [self playPresetOperation:[AKPluckedString presetRoundedPluckedString] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SnappyPluckedString" block:^{
        [self playPresetOperation:[AKPluckedString presetSnappyPluckedString] forDuration:3.0];
    }];

    [self makeSection:@"Sandpaper"];
    [self addButtonWithTitle:@"DefaultSandPaper" block:^{
        [self playPresetOperation:[AKSandPaper presetDefaultSandPaper] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"MuffledSandPaper" block:^{
        [self playPresetOperation:[AKSandPaper presetMuffledSandPaper] forDuration:3.0];
    }];

    [self makeSection:@"Sekere"];
    [self addButtonWithTitle:@"DefaultSekere" block:^{
        [self playPresetOperation:[AKSekere presetDefaultSekere] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ManyBeadsSekere" block:^{
        [self playPresetOperation:[AKSekere presetManyBeadsSekere] forDuration:3.0];
    }];

    [self makeSection:@"Sleighbells"];
    [self addButtonWithTitle:@"DefaultSleighbells" block:^{
        [self playPresetOperation:[AKSleighbells presetDefaultSleighbells] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"OpenBells" block:^{
        [self playPresetOperation:[AKSleighbells presetOpenBells] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SoftBells" block:^{
        [self playPresetOperation:[AKSleighbells presetSoftBells] forDuration:3.0];
    }];

    [self makeSection:@"Sticks"];
    [self addButtonWithTitle:@"DefaultStick" block:^{
        [self playPresetOperation:[AKStick presetDefaultStick] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ThickStick" block:^{
        [self playPresetOperation:[AKStick presetThickStick] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"BundleOfSticks" block:^{
        [self playPresetOperation:[AKStick presetBundleOfSticks] forDuration:3.0];
    }];

    [self makeSection:@"Struck Metal Bar"];
    [self addButtonWithTitle:@"ThickDullMetalBar" block:^{
        [self playPresetOperation:[AKStruckMetalBar presetThickDullMetalBar] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"IntenseDecayingMetalBar" block:^{
        [self playPresetOperation:[AKStruckMetalBar presetIntenseDecayingMetalBar] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SmallHollowMetalBar" block:^{
        [self playPresetOperation:[AKStruckMetalBar presetSmallHollowMetalBar] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"SmallTinklingMetalBar" block:^{
        [self playPresetOperation:[AKStruckMetalBar presetSmallTinklingMetalBar] forDuration:3.0];
    }];

    [self makeSection:@"Tambourine"];
    [self addButtonWithTitle:@"DefaultTambourine" block:^{
        [self playPresetOperation:[AKTambourine presetDefaultTambourine] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"OpenTambourine" block:^{
        [self playPresetOperation:[AKTambourine presetOpenTambourine] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"ClosedTambourine" block:^{
        [self playPresetOperation:[AKTambourine presetClosedTambourine] forDuration:3.0];
    }];


    [self makeSection:@"Vibes"];
    [self addButtonWithTitle:@"TinyVibes" block:^{
        [self playPresetOperation:[AKVibes presetTinyVibes] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"GentleVibes" block:^{
        [self playPresetOperation:[AKVibes presetGentleVibes] forDuration:3.0];
    }];
    [self addButtonWithTitle:@"RingingVibes" block:^{
        [self playPresetOperation:[AKVibes presetRingingVibes] forDuration:3.0];
    }];

}

@end
