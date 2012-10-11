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

@implementation AudioFilePlayer

- (AudioFilePlayerNote *)createNote {
    return [[AudioFilePlayerNote alloc] initWithInstrument:self];
}

- (id)init {
    self = [super init];
    if (self) {
        
        // NOTE BASED CONTROL ==================================================
        AudioFilePlayerNote *note = [self createNote];
        [self addNoteProperty:note.speed];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"hellorcb" ofType:@"aif"];
        OCSSoundFileTable *fileTable;
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
        [self addFTable:fileTable];
        
        OCSLoopingOscillator *oscil;
        oscil = [[OCSLoopingOscillator alloc] initWithSoundFileTable:fileTable
                                                 frequencyMultiplier:note.speed
                                                           amplitude:ocsp(0.5)
                                                                type:kLoopingOscillatorNoLoop];
        [self connect:oscil];
        
        OCSReverb * reverb;
        reverb = [[OCSReverb alloc] initWithMonoInput:oscil
                                        feedbackLevel:ocsp(0.85)
                                      cutoffFrequency:ocsp(12000)];
        [self connect:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSAudio * audio;
        audio = [[OCSAudio alloc] initWithLeftInput:reverb.leftOutput
                                         rightInput:reverb.rightOutput];
        [self connect:audio];
    }
    return self;
}

@end

@implementation AudioFilePlayerNote

@synthesize speed;

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    self = [super initWithInstrument:anInstrument];
    if (self) {
        speed = [[OCSNoteProperty alloc] initWithValue:kSpeedInit
                                              minValue:kSpeedMin
                                              maxValue:kSpeedMax];
        [self addProperty:speed];
    }
    return self;
}


@end
