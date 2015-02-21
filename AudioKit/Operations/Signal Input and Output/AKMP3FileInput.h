//
//  AKMP3FileInput.h
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Customized by Aurelius Prochazka on 12/25/14.
//
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Reads stereo audio data from an external MP3 file.
 */

@interface AKMP3FileInput : AKStereoAudio

/// Instantiates the mp3 file input with default values
/// @param filename Input MP3 Filename.
- (instancetype)initWithFilename:(NSString *)filename;

/// Instantiates the mp3 file input with default values
/// @param filename Input MP3 Filename.
+ (instancetype)mp3WithFilename:(NSString *)filename;

/// Instantiates the mp3 file input with default values
/// @param filename Input MP3 Filename.
/// @param startTime Time in second to start the playback (useful for pause/resume) [Default: 0]
- (instancetype)initWithFilename:(NSString *)filename
                       startTime:(AKConstant *)startTime;

/// Set the start time (useful for pause/resume
@property (nonatomic) AKConstant *startTime;

/// Set an optional start time
/// @param startTime Time in second to start the playback (useful for pause/resume)
- (void)setOptionalStartTime:(AKConstant *)startTime;

@end
