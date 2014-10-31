//
//  ToneGenerator.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ToneGenerator.h"

@implementation ToneGenerator

- (instancetype)init {
    self = [super init];
    if (self) {
        // NOTE BASED CONTROL ==================================================
        ToneGeneratorNote *note = [[ToneGeneratorNote alloc] init];
        [self addNoteProperty:note.frequency];
        
        // INSTRUMENT CONTROL ==================================================
        _volume  = [[AKInstrumentProperty alloc] initWithValue:0.2
                                                           minimum:0.0
                                                           maximum:1.0];
        [self addProperty:_volume];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKSineTable *sineTable = [[AKSineTable alloc] init];
        [self addFTable:sineTable];
        
        AKFMOscillator *fmOscillator;
        fmOscillator = [[AKFMOscillator alloc] initWithFTable:sineTable
                                                baseFrequency:note.frequency
                                            carrierMultiplier:akp(2)
                                         modulatingMultiplier:akp(2.3)
                                              modulationIndex:akp(15)
                                                    amplitude:_volume];
        [self connect:fmOscillator];
        
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio = [[AKAudioOutput alloc] initWithAudioSource:fmOscillator];
        [self connect:audio];
        
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
        _frequency = [[AKNoteProperty alloc] initWithMinimum:440
                                                     maximum:880];
        [self addProperty:_frequency];
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
