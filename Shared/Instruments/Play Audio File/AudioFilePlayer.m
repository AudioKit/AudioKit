//
//  AudioFilePlayer.m
//  Objective-C Sound Example
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
    OCSEventProperty *spd;
}
@end

@implementation AudioFilePlayer

@synthesize speed = spd;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        spd = [[OCSEventProperty alloc] initWithMinValue:kSpeedMin  maxValue:kSpeedMax];
        [spd setConstant:[OCSConstant parameterWithString:@"Speed"]]; 
        [self addEventProperty:spd];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"hellorcb" ofType:@"aif"];
        OCSSoundFileTable *fileTable;
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
        [self addFTable:fileTable];
        
        OCSLoopingOscillator *oscil;
        oscil = [[OCSLoopingOscillator alloc] initWithSoundFileTable:fileTable
                                                 frequencyMultiplier:[spd constant]
                                                           amplitude:ocsp(0.5)
                                                                type:kLoopingOscillatorNoLoop];
        [self connect:oscil];
        
        OCSReverb * reverb;
        reverb = [[OCSReverb alloc] initWithMonoInput:[oscil output] 
                                        feedbackLevel:ocsp(0.85)
                                      cutoffFrequency:ocsp(12000)];
        [self connect:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSAudio * audio;
        audio = [[OCSAudio alloc] initWithLeftInput:[reverb leftOutput] 
                                         rightInput:[reverb rightOutput]]; 
        [self connect:audio];
    }
    return self;
}

@end
