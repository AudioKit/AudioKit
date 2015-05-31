//
//  AKMP3FileInput.h
//  AudioKit
//
//  Auto-generated on 3/13/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Reads stereo audio data from an external MP3 file.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKMP3FileInput : AKStereoAudio
/// Instantiates the mp3 file input with all values
/// @param filename Input MP3 Filename. 
/// @param startTime Number of seconds into the file to start playback. [Default Value: 0]
- (instancetype)initWithFilename:(NSString *)filename
                       startTime:(AKConstant *)startTime;

/// Instantiates the mp3 file input with default values
/// @param filename Input MP3 Filename.
- (instancetype)initWithFilename:(NSString *)filename;

/// Instantiates the mp3 file input with default values
/// @param filename Input MP3 Filename.
+ (instancetype)mp3WithFilename:(NSString *)filename;

/// Number of seconds into the file to start playback. [Default Value: 0]
@property (nonatomic) AKConstant *startTime;

/// Set an optional start time
/// @param startTime Number of seconds into the file to start playback. [Default Value: 0]
- (void)setOptionalStartTime:(AKConstant *)startTime;

@end
NS_ASSUME_NONNULL_END
