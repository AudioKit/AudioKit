//
//  UDOInstrument.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOInstrument.h"

#import "UDOMSROscillator.h"
#import "UDOCsGrainCompressor.h"
#import "UDOCsGrainPitchShifter.h"

@implementation UDOInstrument

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // NOTE BASED CONTROL ==================================================
        UDOInstrumentNote *note = [[UDOInstrumentNote alloc] init];
        [self addNoteProperty:note.frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        UDOMSROscillator *msrOsc;
        msrOsc = [[UDOMSROscillator alloc] initWithType:kMSROscillatorTypeTriangle
                                              frequency:note.frequency
                                              amplitude:akp(0.5)];
        [self addUDO:msrOsc];
        
        UDOCSGrainPitchShifter *ps;
        ps = [[UDOCSGrainPitchShifter alloc] initWithSourceStereoAudio:[AKStereoAudio stereoFromMono:msrOsc]
                                                             basePitch:akp(2.7)
                                                       offsetFrequency:akp(0)
                                                         feedbackLevel:akp(0.9)];
        [self addUDO:ps];
        
        UDOCSGrainCompressor *comp;
        comp = [[UDOCSGrainCompressor alloc] initWithSourceStereoAudio:ps
                                                             threshold:akp(-2.0)
                                                      compressionRatio:akp(0.5)
                                                            attackTime:akp(0.1)
                                                           releaseTime:akp(0.2)];
        [self addUDO:comp];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *stereoOutput = [[AKAudioOutput alloc] initWithSourceStereoAudio:comp];
        [self connect:stereoOutput];
    }
    return self;
}

@end

@implementation UDOInstrumentNote

- (instancetype)init {
    self = [super init];
    if (self) {
        _frequency = [[AKNoteProperty alloc] initWithValue:220
                                               minimumValue:110
                                               maximumValue:880];
        [self addProperty:_frequency];
    }
    return self;
}


- (instancetype)initWithFrequency:(float)frequency {
    self = [self init];
    if (self) {
        self.frequency.value = frequency;
    }
    return self;
}



@end
