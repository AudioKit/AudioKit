//
//  EffectsProcessor.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "EffectsProcessor.h"

@implementation EffectsProcessor

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
{
    self = [super init];
    if (self) {
        
        // INSTRUMENT CONTROL ==================================================
        _reverb  = [[AKInstrumentProperty alloc] initWithValue:0.0
                                                       minimum:0.0
                                                       maximum:1.0];
        [self addProperty:_reverb];
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKReverb *reverb = [[AKReverb alloc] initWithAudioSource:audioSource
                                                   feedbackLevel:_reverb
                                                 cutoffFrequency:akp(4000)];
        [self connect:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithSourceStereoAudio:reverb];
        [self connect:audio];
        
        // RESET INPUTS ========================================================
        [self resetParameter:audioSource];
    }
    return self;
}

@end
