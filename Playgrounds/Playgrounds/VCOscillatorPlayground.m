//
//  VCOscillatorPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface Instrument : AKInstrument
@property AKInstrumentProperty *frequency;
@end

@interface Note : AKNote
@property AKNoteProperty *waveformType;
@end

@implementation Instrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frequency = [[AKInstrumentProperty alloc] initWithValue:323.0*2 minimum:0.0 maximum:2000.0];
        Note *note = [[Note alloc] init];
        AKVCOscillator *vco = [AKVCOscillator oscillator];
        vco.frequency = _frequency;
        vco.amplitude = akp(0.5);
        vco.frequency = _frequency;
        vco.waveformType = note.waveformType;
        [self setAudioOutput:vco];
    }
    return self;
}
@end


@implementation Note

- (instancetype)init
{
    self = [super init];
    if (self) {
        _waveformType = [self createPropertyWithValue:0 minimum:0 maximum:100];
    }
    return self;
}
- (instancetype)initWithWaveformType:(AKConstant *)waveformType
{
    self = [self init];
    if (self) {
        _waveformType.value = waveformType.value;
    }
    return self;
}

@end

@implementation Playground

- (void) setup
{
    [super setup];
}

- (void)run
{
    [super run];
    [self addStereoAudioOutputPlot];
    
    Instrument *instrument = [[Instrument alloc] init];
    [AKOrchestra addInstrument:instrument];
    
    AKPlaygroundPropertySlider(Frequency, instrument.frequency);
    
    Note *note = [[Note alloc] init];
    
    AKPlaygroundButton(@"Play Triangle Wave",
                       note.waveformType.value = [[AKVCOscillator waveformTypeForTriangle] value];
                       [instrument playNote:note];
                       );
    AKPlaygroundButton(@"Play Triangle WithRamp",
                       note.waveformType.value = [[AKVCOscillator waveformTypeForTriangleWithRamp] value];
                       [instrument playNote:note];
                       );
    AKPlaygroundButton(@"Play Sawtooth Wave",
                       note.waveformType.value = [[AKVCOscillator waveformTypeForSawtooth] value];
                       [instrument playNote:note];
                       );
    AKPlaygroundButton(@"Play Square with PWM",
                       note.waveformType.value = [[AKVCOscillator waveformTypeForSquareWithPWM] value];
                       [instrument playNote:note];
                       );
    AKPlaygroundButton(@"Play Integrated",
                       note.waveformType.value = [[AKVCOscillator waveformTypeForIntegratedSawtooth] value];
                       [instrument playNote:note];
                       );
    AKPlaygroundButton(@"Stop", [instrument stop];);
}

@end