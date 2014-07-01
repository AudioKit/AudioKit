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
        
        // INSTRUMENT DEFINITION ===============================================
        
        AKReverb * reverb = [[AKReverb alloc] initWithAudioSource:audioSource
                                                      feedbackLevel:akp(0.8)
                                                    cutoffFrequency:akp(12000)];
        [self connect:reverb];
        
        // AUDIO OUTPUT ========================================================
            
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithSourceStereoAudio:[reverb scaledBy:akp(0.2)] ];
        [self connect:audio];
        
        // RESET INPUTS ========================================================
        [self resetParam:audioSource];
    }
    return self;
}

@end
