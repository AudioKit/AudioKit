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
    AKInstrument *presetPlayer;
    AKInstrument *instrumentPlayer;
    int presetNumber;
    int instrumentNumber;
    UILabel *presetLabel;
    UILabel *instrumentLabel;
}

- (void)run
{
    [super run];

    soundFont = [[AKSoundFont alloc] initWithFilename:[AKManager pathToSoundFile:@"GeneralMidi" ofType:@"sf2"]];

    [soundFont fetchPresets:^(AKSoundFont *font) {
        // Do nothing
    }];

    presetPlayer = [AKInstrument instrumentWithNumber:1];
    instrumentPlayer = [AKInstrument instrumentWithNumber:2];

    [AKOrchestra start];

    presetNumber = 0;
    instrumentNumber = 0;

    [self updatePresetPlayer];
    [self updateInstrumentPlayer];

    presetLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    presetLabel.text = [[[soundFont presets] firstObject] name];
    [timelineViewController addView:presetLabel];

    [self addButtonWithTitle:@"Up Preset" block:^{
        if (presetNumber < soundFont.presets.count) {
            presetNumber = presetNumber + 1;
            [self updatePresetPlayer];
        }
    }];

    [self addButtonWithTitle:@"Down Preset" block:^{
        if (presetNumber > 0) {
            presetNumber = presetNumber - 1;
            [self updatePresetPlayer];
        }
    }];
    [self addButtonWithTitle:@"Play Preset" block:^{
        [presetPlayer playForDuration:1.0];
    }];

    instrumentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 30)];
    instrumentLabel.text = [[soundFont.instruments firstObject] name];
    [timelineViewController addView:instrumentLabel];

    [self addButtonWithTitle:@"Up Instrument" block:^{
        if (instrumentNumber < soundFont.instruments.count) {
            instrumentNumber = instrumentNumber + 1;
            [self updateInstrumentPlayer];
        }
    }];

    [self addButtonWithTitle:@"Down Instrument" block:^{
        if (instrumentNumber > 0) {
            instrumentNumber = instrumentNumber - 1;
            [self updateInstrumentPlayer];
        }
    }];


    [self addButtonWithTitle:@"Play Instrument" block:^{
        [instrumentPlayer playForDuration:1.0];
    }];
}

- (void)updatePresetPlayer
{
    presetPlayer = [AKInstrument instrumentWithNumber:1];
    AKSoundFontPreset *soundFontPreset = soundFont.presets[presetNumber];
    presetLabel.text = soundFontPreset.name;

    AKSoundFontPresetPlayer *player = [[AKSoundFontPresetPlayer alloc] initWithSoundFontPreset:soundFontPreset];
    player.frequencyMultiplier = akp(1.5);
    player.amplitude = akp(64);

    [presetPlayer setStereoAudioOutput:player];
    [AKOrchestra addInstrument:presetPlayer];
}

- (void)updateInstrumentPlayer
{
    instrumentPlayer = [AKInstrument instrumentWithNumber:2];
    AKSoundFontInstrument *soundFontInstrument = soundFont.instruments[instrumentNumber];
    instrumentLabel.text = soundFontInstrument.name;
    AKSoundFontInstrumentPlayer *player = [[AKSoundFontInstrumentPlayer alloc] initWithSoundFontInstrument:soundFontInstrument];
    player.frequencyMultiplier = akp(1.5);
    player.amplitude = akp(1);

    [instrumentPlayer setStereoAudioOutput:player];
    [AKOrchestra addInstrument:instrumentPlayer];
}

@end
