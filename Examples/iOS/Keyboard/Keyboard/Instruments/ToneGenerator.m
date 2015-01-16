//
//  ToneGenerator.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "ToneGenerator.h"

@implementation ToneGenerator

- (instancetype)init {
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ==================================================
        ToneGeneratorNote *note = [[ToneGeneratorNote alloc] init];
        [self addNoteProperty:note.frequency];
        [self addNoteProperty:note.amplitude];
        
        // INSTRUMENT CONTROL ==================================================
        _toneColor  = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                          minimum:0.1
                                                          maximum:1.0];
        [self addProperty:_toneColor];
    
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKLinearADSREnvelope  *adsr = [AKLinearADSREnvelope envelope];
        [self connect:adsr];
        
        AKFMOscillator *fmOscillator = [AKFMOscillator oscillator];
        fmOscillator.baseFrequency = note.frequency;
        fmOscillator.carrierMultiplier = [_toneColor scaledBy:akp(20)];
        fmOscillator.modulatingMultiplier = [_toneColor scaledBy:akp(12)];
        fmOscillator.modulationIndex = [_toneColor scaledBy:akp(12)];
        fmOscillator.amplitude = [adsr scaledBy:akp(0.15)];
        [self connect:fmOscillator];
        
        // EXTERNAL OUTPUTS ====================================================
        // After your instrument is set up, define outputs available to others
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:fmOscillator];
    }
    return self;
}

@end

// -----------------------------------------------------------------------------
#  pragma mark - Tone Generator Note
// -----------------------------------------------------------------------------


@implementation ToneGeneratorNote

- (instancetype)init {
    self = [super init];
    if (self) {
        _frequency = [[AKNoteProperty alloc] initWithMinimum:440 maximum:880];
        _amplitude = [[AKNoteProperty alloc] initWithMinimum:0 maximum:1];
        [self addProperty:_frequency];
        [self addProperty:_amplitude];
        _amplitude.value = 1.0;
    }
    return self;
}

- (instancetype)initWithFrequency:(float)frequency {
    self = [self init];
    if (self) {
        _frequency.value = frequency;
    }
    return self;
}

@end
