//
//  AKMonoFileInput.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Reads mono audio data from a file.
 */

@interface AKMonoFileInput : AKAudio

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
@property (nonatomic) AKParameter *speed;

/// Set an optional speed
/// @param speed Speed of the playback relative to 1 [Default Value: 1]
- (void)setOptionalSpeed:(AKParameter *)speed;

/// Set the start time (useful for pause/resume
@property (nonatomic) AKConstant *startTime;

/// Set an optional start time
/// @param startTime Time in second to start the playback (useful for pause/resume)
- (void)setOptionalStartTime:(AKConstant *)startTime;

@end
