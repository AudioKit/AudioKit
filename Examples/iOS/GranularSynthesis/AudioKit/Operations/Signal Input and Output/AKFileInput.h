//
//  AKFileInput.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKStereoAudio.h"
#import "AKParameter+Operation.h"

/** Reads stereo audio data from a file.
 */

@interface AKFileInput : AKStereoAudio

/// Create a file input.
/// @param fileName Location of the file on disk.
- (instancetype)initWithFilename:(NSString *)fileName;

@end
