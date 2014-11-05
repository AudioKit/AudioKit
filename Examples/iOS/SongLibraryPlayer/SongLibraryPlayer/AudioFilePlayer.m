//
//  AudioFilePlayer.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"

@implementation AudioFilePlayer

- (instancetype)init {
    self = [super init];
    if (self) {

        // INSTRUMENT BASED CONTROL ============================================
        _reverbAmount = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                            minimum:0
                                                            maximum:1.0];
        [self addProperty:_reverbAmount];
        _mix = [[AKInstrumentProperty alloc] initWithValue:0.5
                                                   minimum:0
                                                   maximum:1.0];
        [self addProperty:_mix];

        // INSTRUMENT DEFINITION ===============================================

        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"exported" ofType:@"wav"];
        NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [docDirs objectAtIndex:0];
        NSString *outPath = [[docDir stringByAppendingPathComponent:@"exported"]
                             stringByAppendingPathExtension:@"wav"];

        file = outPath;

        AKFileInput *fileIn = [[AKFileInput alloc] initWithFilename:file];

        [self connect:fileIn];

        AKReverb *reverb;
        reverb = [[AKReverb alloc] initWithSourceStereoAudio:fileIn
                                               feedbackLevel:_reverbAmount
                                             cutoffFrequency:akp(12000)];
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
        //audio = [[AKAudioOutput alloc] initWithSourceStereoAudio:[fileIn plus:reverb]];
        audio = [[AKAudioOutput alloc] initWithLeftAudio:leftMix
                                              rightAudio:rightMix];

        [self connect:audio];
    }
    return self;
}

@end

@implementation AudioFilePlayerNote

- (instancetype)init;
{
    self = [super init];
    if(self) {

    }
    return self;
}


@end
