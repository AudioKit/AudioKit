//
//  EffectsProcessor.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
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
        
        AKReverb *reverb = [[AKReverb alloc] initWithInput:audioSource];
        reverb.feedback = _reverb;
        [self connect:reverb];
        
        AKMix *leftMix = [[AKMix alloc] initWithInput1:reverb.leftOutput
                                                input2:audioSource
                                                balance:akp(0.5)];
        [self connect:leftMix];
        
        AKMix *rightMix = [[AKMix alloc] initWithInput1:reverb.rightOutput
                                                 input2:audioSource
                                                 balance:akp(0.5)];
        [self connect:rightMix];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithLeftAudio:leftMix rightAudio:rightMix];
        [self connect:audio];
        
        // RESET INPUTS ========================================================
        [self resetParameter:audioSource];
    }
    return self;
}

@end
