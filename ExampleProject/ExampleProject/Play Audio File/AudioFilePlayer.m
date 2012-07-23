//
//  AudioFilePlayer.m
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AudioFilePlayer.h"
#import "OCSLoopingOscillator.h"
#import "OCSReverb.h"
#import "OCSAudio.h"

#import "OCSEvent.h"

@interface AudioFilePlayer () {
    OCSNoteProperty *spd;
}
@end

@implementation AudioFilePlayer

@synthesize speed = spd;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        spd = [[OCSNoteProperty alloc] initWithMinValue:kSpeedMin  maxValue:kSpeedMax];
        [spd setConstant:[OCSConstant parameterWithString:@"Speed"]]; 
        [self addNoteProperty:spd];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"hellorcb" ofType:@"aif"];
        OCSSoundFileTable *fileTable;
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
        [self addFTable:fileTable];
        
        OCSLoopingOscillator *oscil;
        oscil = [[OCSLoopingOscillator alloc] initWithSoundFileTable:fileTable
                                                 frequencyMultiplier:[spd constant]
                                                           amplitude:ocsp(0.5)];
        [self addOpcode:oscil];
        
        OCSReverb * reverb;
        reverb = [[OCSReverb alloc] initWithMonoInput:[oscil output] 
                                        feedbackLevel:ocsp(0.85)
                                      cutoffFrequency:ocsp(12000)];
        [self addOpcode:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSAudio * audio;
        audio = [[OCSAudio alloc] initWithLeftInput:[reverb leftOutput] 
                                         rightInput:[reverb rightOutput]]; 
        [self addOpcode:audio];
    }
    return self;
}

@end
