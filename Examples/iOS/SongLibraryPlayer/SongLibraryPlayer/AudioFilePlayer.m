//
//  AudioFilePlayer.m
//  Song Library Player Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AudioFilePlayer.h"

@implementation AudioFilePlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // INSTRUMENT BASED CONTROL ============================================
        _reverbFeedback = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                              minimum:0
                                                              maximum:1.0];
        [self addProperty:_reverbFeedback];
        
        _mix = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                   minimum:0
                                                   maximum:1.0];
        [self addProperty:_mix];
        
        // INSTRUMENT DEFINITION ===============================================
        NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [docDirs objectAtIndex:0];
        NSString *file = [[docDir stringByAppendingPathComponent:@"exported"]
                          stringByAppendingPathExtension:@"wav"];
        
        AKFileInput *fileIn = [[AKFileInput alloc] initWithFilename:file];
        
        [self connect:fileIn];
        
        AKReverb *reverb;
        reverb = [[AKReverb alloc] initWithInput:fileIn];
        reverb.feedback = _reverbFeedback;
        [self connect:reverb];
        
        AKMixedAudio *leftMix;
        leftMix = [[AKMixedAudio alloc] initWithSignal1:fileIn.leftOutput
                                                signal2:reverb.leftOutput
                                                balance:_mix];
        [self connect:leftMix];
        
        AKMixedAudio *rightMix;
        rightMix = [[AKMixedAudio alloc] initWithSignal1:fileIn.rightOutput
                                                 signal2:reverb.rightOutput
                                                 balance:_mix];
        [self connect:rightMix];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithLeftAudio:leftMix
                                              rightAudio:rightMix];
        
        [self connect:audio];
    }
    return self;
}

@end
