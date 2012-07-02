//
//  AudioFilePlayer.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"
#import "OCSLoopingOscillator.h"
#import "OCSReverb.h"
#import "OCSAudio.h"

@interface AudioFilePlayer () {
    OCSProperty *frequencyMultiplier;
}
@end

@implementation AudioFilePlayer

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequencyMultiplier = [[OCSProperty alloc] init];
        [frequencyMultiplier setConstant:[OCSParamConstant paramWithString:@"FrequencyMultiplier"]]; 
        [self addProperty:frequencyMultiplier];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"hellorcb" ofType:@"aif"];
        OCSSoundFileTable *fileTable;
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
        [self addFTable:fileTable];
        
        OCSLoopingOscillator *oscil;
        oscil = [[OCSLoopingOscillator alloc] initWithSoundFileTable:fileTable
                                                 frequencyMultiplier:[frequencyMultiplier constant]
                                                           amplitude:ocsp(0.5)];
        [self addOpcode:oscil];
        
        OCSReverb * reverb;
        reverb = [[OCSReverb alloc] initWithMonoInput:[oscil output1] 
                                        feedbackLevel:ocsp(0.85)
                                      cutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSAudio * audio;
        audio = [[OCSAudio alloc] initWithLeftInput:[reverb outputLeft] 
                                         rightInput:[reverb outputRight]]; 
        [self addOpcode:audio];
    }
    return self;
}

- (void)play {
    [self playNoteForDuration:3.0f];
}

- (void)playWithFrequencyMultiplier:(float)freqMutiplier {
    frequencyMultiplier.value = freqMutiplier;
    NSLog(@"Playing file at %0.2fx original speed", freqMutiplier);
    [self playNoteForDuration:3.0f];
}


@end
