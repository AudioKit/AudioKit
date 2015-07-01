//
//  SoundFontPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/29/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground {
    AKSoundFont *soundFont;
    AKInstrument *instrument;
    int presetNumber;
    UILabel *label;
}

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];

    soundFont = [[AKSoundFont alloc] initWithFilename:[AKManager pathToSoundFile:@"GeneralMidi" ofType:@"sf2"]];
    instrument = [AKInstrument instrumentWithNumber:1];
    presetNumber = 0;

    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    label.text = [[[soundFont presets] firstObject] name];
    [timelineViewController addView:label];

    [self updateInstrument];

    [self addButtonWithTitle:@"Up Preset" block:^{
        if (presetNumber < soundFont.presets.count) {
            presetNumber = presetNumber + 1;
            [self updateInstrument];
        }
    }];

    [self addButtonWithTitle:@"Down Preset" block:^{
        if (presetNumber > 0) {
            presetNumber = presetNumber - 1;
            [self updateInstrument];
        }
    }];

    [self addButtonWithTitle:@"Play" block:^{
        [instrument playForDuration:1.0];
    }];
}

- (void)updateInstrument
{
    instrument = [AKInstrument instrumentWithNumber:1];
    AKSoundFontPreset *soundFontPreset = [[soundFont presets] objectAtIndex:presetNumber];
    label.text = soundFontPreset.name;
    AKSoundFontPresetPlayer *player = [[AKSoundFontPresetPlayer alloc] initWithSoundFontPreset:soundFontPreset];
    player.frequencyMultiplier = akp(1.5);
    player.amplitude = akp(0.1);

    [instrument setStereoAudioOutput:player];
    [AKOrchestra addInstrument:instrument];

}

@end
