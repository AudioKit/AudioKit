//
//  AKStereoAudioFilePlayer.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKStereoAudioFilePlayer.h"

@implementation AKStereoAudioFilePlayer

- (instancetype)init {
    NSArray<NSString *> *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    NSString *file = [[docDir stringByAppendingPathComponent:@"exported"]
                      stringByAppendingPathExtension:@"wav"];
    return [self initWithFilename:file];
}

- (instancetype)initWithFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        
        AKStereoAudioFilePlayback *note = [[AKStereoAudioFilePlayback alloc] init];
        
        _filePosition = [[AKInstrumentProperty alloc] initWithValue:0];
        
        AKFileInput *fileIn = [[AKFileInput alloc] initWithFilename:filename];
        fileIn.startTime = note.startTime;
        fileIn.loop = YES;
        
        // Output to global effects processing
        _auxilliaryOutput = [AKStereoAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:fileIn];
        
        [self assignOutput:_filePosition to:akp(64.0/44100.0)];
    }
    return self;
}

@end

@implementation AKStereoAudioFilePlayback

- (instancetype)init {
    self = [super init];
    if (self) {
        _startTime = [[AKNoteProperty alloc] initWithValue:0
                                                   minimum:0
                                                   maximum:100000000];
    }
    return self;
}


- (instancetype)initWithStartTime:(float)startTime {
    self = [self init];
    if (self) {
        _startTime.value = startTime;
    }
    return self;
}


@end
