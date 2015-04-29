//
//  VCOscillatorPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"
#import "VCOscillatorInstrument.h"

@implementation Playground

- (void)run
{
    [super run];

    VCOscillatorInstrument *vcoInstrument = [[VCOscillatorInstrument alloc] initWithNumber:1];
    [AKOrchestra addInstrument:vcoInstrument];

    VCOscillatorNote *note = [[VCOscillatorNote alloc] init];

    [self addSliderForProperty:vcoInstrument.amplitude title:@"Amplitude"];
    [self addSliderForProperty:note.frequency title:@"Frequency"];

    [self addButtonWithTitle:@"Play Square Wave" block:^{
        note.waveformType.value = [[AKVCOscillator waveformTypeForSquare] value];
        [vcoInstrument playNote:note];
    }];

    [self addButtonWithTitle:@"Play Triangle Wave" block:^{
        note.waveformType.value = [[AKVCOscillator waveformTypeForTriangle] value];
        [vcoInstrument playNote:note];
    }];
    [self addButtonWithTitle:@"Play Sawtooth Wave" block:^{
        note.waveformType.value = [[AKVCOscillator waveformTypeForSawtooth] value];
        [vcoInstrument playNote:note];
    }];
    [self addButtonWithTitle:@"Play Integrated" block:^{
        note.waveformType.value = [[AKVCOscillator waveformTypeForIntegratedSawtooth] value];
        [vcoInstrument playNote:note];
    }];
    [self addButtonWithTitle:@"Stop" block:^{
        [vcoInstrument stop];
    }];

    [self addAudioOutputPlot];
    [self addAudioOutputFFTPlot];
}

@end
