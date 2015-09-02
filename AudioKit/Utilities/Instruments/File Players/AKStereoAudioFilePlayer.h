//
//  AKStereoAudioFilePlayer.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/1/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


#import "AKFoundation.h"

@interface AKStereoAudioFilePlayer : AKInstrument

// Audio outlet for global effects processing
@property (readonly) AKStereoAudio *auxilliaryOutput;
@property (readonly) AKInstrumentProperty *filePosition;

- (instancetype)initWithFilename:(NSString *)filename;

@end

@interface AKStereoAudioFilePlayback : AKNote

@property AKNoteProperty *startTime;

- (instancetype)initWithStartTime:(float)startTime;

@end