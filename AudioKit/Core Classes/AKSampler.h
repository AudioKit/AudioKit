//
//  AKSampler.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/8/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKSampler : NSObject

@property (readonly) NSArray *trackNames;

- (void)startRecordingToTrack:(NSString *)trackName;
- (void)stopRecordingToTrack:(NSString *)trackName;

- (void)startPlayingTrack:(NSString *)trackName;
- (void)stopPlayingTrack:(NSString *)trackName;

@end
