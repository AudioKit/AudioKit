//
//  AKSampler.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/8/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import <Foundation/Foundation.h>

/** AKSampler is a simple multi-track capable recorder and playback system.
 */
@interface AKSampler : NSObject

@property (readonly) NSArray *trackNames;

/// Start recording the playback with a referencing track name
/// @param trackName A string uniquely identifying the track to record onto
- (void)startRecordingToTrack:(NSString *)trackName;

/// Stop recording the playback and save the recording to a given track name
/// @param trackName A string uniquely identify the track to recorded onto
- (void)stopRecordingToTrack:(NSString *)trackName;

/// Start playback with a referencing track name
/// @param trackName A string uniquely identify the track to play
- (void)startPlayingTrack:(NSString *)trackName;

/// Stop playback of a track with a referencing track name
/// @param trackName A string uniquely identify the track to stop playing
- (void)stopPlayingTrack:(NSString *)trackName;

@end
