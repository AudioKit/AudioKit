//
//  AudioFilePlayer.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AudioFilePlayer.h"

@implementation AudioFilePlayer

- (instancetype)init {
    self = [super init];
    if (self) {
        
        // NOTE BASED CONTROL ==================================================
        AudioFilePlayerNote *note = [[AudioFilePlayerNote alloc] init];
        [self addNoteProperty:note.speed];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"blaster" ofType:@"aiff"];
        AKSoundFile *fileTable;
        fileTable = [[AKSoundFile alloc] initWithFilename:file];
        [self connect:fileTable];
        
        AKLoopingOscillator *oscil;
        oscil = [[AKLoopingOscillator alloc] initWithSoundFileTable:fileTable
                                                frequencyMultiplier:note.speed
                                                          amplitude:akp(0.5)
                                                               type:AKLoopingOscillatorTypeNoLoop];
        [self connect:oscil];
        
        AKReverb *reverb;
        reverb = [[AKReverb alloc] initWithAudioSourceLeftChannel:oscil
                                          audioSourceRightChannel:oscil
                                                         feedback:akp(0.85)
                                                  cutoffFrequency:akp(12000)];
        [self connect:reverb];
        
        // AUDIO OUTPUT ========================================================
        
        AKAudioOutput *audio;
        audio = [[AKAudioOutput alloc] initWithStereoAudioSource:reverb];
        [self connect:audio];
    }
    return self;
}

@end

// -----------------------------------------------------------------------------
#  pragma mark - Instrument Note
// -----------------------------------------------------------------------------

@implementation AudioFilePlayerNote

- (instancetype)init;
{
    self = [super init];
    if(self) {
        _speed = [[AKNoteProperty alloc] initWithValue:1.0
                                               minimum:0.2
                                               maximum:2.0];
        [self addProperty:_speed];
    }
    return self;
}
- (instancetype)initWithSpeed:(float)speed;
{
    self = [self init];
    if(self) {
        self.speed.value = speed;
    }
    return self;
}

@end
