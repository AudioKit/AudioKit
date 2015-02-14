//
//  AKFileInput.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Reads stereo audio data from a file.
 */

@interface AKFileInput : AKStereoAudio

/// Create a file input.
/// @param fileName Location of the file on disk.
- (instancetype)initWithFilename:(NSString *)fileName;

/// Create a file input.
/// @param fileName Location of the file on disk.
/// @param speed Speed of the playback relative to 1 [Default Value: 1]
/// @param startTime Time in second to start the playback (useful for pause/resume)
- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKParameter *)speed
                       startTime:(AKConstant *)startTime;

/// Speed of the playback relative to 1 [Default Value: 1]
@property AKParameter *speed;

/// Set an optional speed
/// @param speed Speed of the playback relative to 1 [Default Value: 1]
- (void)setOptionalSpeed:(AKParameter *)speed;

/// Set the start time (useful for pause/resume
@property AKConstant *startTime;

/// Set an optional speed
/// @param startTime Time in second to start the playback (useful for pause/resume)
- (void)setOptionalStartTime:(AKConstant *)startTime;

/// Normalize the output
/// @param maximumAmplitude The maximum amplitude will be normalized to this amount.
- (void)normalizeTo:(float)maximumAmplitude;

@end
