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

//@interface AudioFilePlayer () {
//    OCSEventProperty *spd;
//}
//@end

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
                                                 frequencyMultiplier:[note.speed constant]
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

@implementation AudioFilePlayerNote

@synthesize speed;

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    self = [super initWithInstrument:anInstrument];
    if (self) {
        NSString *speedString = @"Speed";
        speed = [[OCSNoteProperty alloc] initWithNote:self
                                             initialValue:kSpeedInit
                                                 minValue:kSpeedMin
                                                 maxValue:kSpeedMax];
        [speed setConstant:[OCSConstant parameterWithString:speedString]];
        [self.properties setValue:speed forKey:speedString];
    }
    return self;
}


@end
