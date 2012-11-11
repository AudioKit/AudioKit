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
#import "OCSAudioOutput.h"

#import "OCSEvent.h"

@implementation AudioFilePlayer

- (id)init {
    self = [super init];
    if (self) {
        
        // NOTE BASED CONTROL ==================================================
        AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
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
        reverb = [[OCSReverb alloc] initWithAudioSource:oscil
                                          feedbackLevel:ocsp(0.85)
                                        cutoffFrequency:ocsp(12000)];
        [self connect:reverb];
        
        // AUDIO OUTPUT ========================================================

        OCSAudioOutput * audio;
        audio = [[OCSAudioOutput alloc] initWithSourceStereoAudio:reverb];
        [self connect:audio];
    }
    return self;
}

@end

@implementation AudioFilePlayerNote
@synthesize speed = _speed;

- (id)init;
{
    self = [super init];
    if(self) {
        _speed = [[OCSNoteProperty alloc] initWithValue:kSpeedInit
                                               minValue:kSpeedMin
                                               maxValue:kSpeedMax];
        [self addProperty:_speed];
    }
    return self;
}
- (id)initWithSpeed:(float)speed;
{
    self = [self init];
    if(self) {
        self.speed.value = speed;
    }
    return self;
}

@end
