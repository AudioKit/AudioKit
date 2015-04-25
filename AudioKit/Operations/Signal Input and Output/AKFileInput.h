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

NS_ASSUME_NONNULL_BEGIN
@interface AKFileInput : AKStereoAudio

/// Create a file input.
/// @param fileName Location of the file on disk.
- (instancetype)initWithFilename:(NSString *)fileName;

/// Create a file input.
/// @param fileName Location of the file on disk.
/// @param speed Speed of the playback relative to 1 [Default Value: 1]
/// @param startTime Time in second to start the playback (useful for pause/resume)
/// @param loop Whether or not to loop the playback (Default Value: NO)
- (instancetype)initWithFilename:(NSString *)fileName
                           speed:(AKParameter *)speed
                       startTime:(AKConstant *)startTime
                            loop:(BOOL)loop;

/// Speed of the playback relative to 1 [Default Value: 1]
@property (nonatomic) AKParameter *speed;

/// Set an optional speed
/// @param speed Speed of the playback relative to 1 [Default Value: 1]
- (void)setOptionalSpeed:(AKParameter *)speed;

/// Set the start time (useful for pause/resume)
@property (nonatomic) AKConstant *startTime;

/// Set an optional start time
/// @param startTime Time in second to start the playback (useful for pause/resume)
- (void)setOptionalStartTime:(AKConstant *)startTime;

/// Whether or not to loop playback (Default Value: NO)
@property (nonatomic) BOOL loop;

/// Set whether to loop playback
/// @param loop Whether or not to loop the playback (Default Value: NO)
- (void)setOptionalLoop:(BOOL)loop;

/// Normalize the output
/// @param maximumAmplitude The maximum amplitude will be normalized to this amount.
- (void)normalizeTo:(float)maximumAmplitude;

@end
NS_ASSUME_NONNULL_END
