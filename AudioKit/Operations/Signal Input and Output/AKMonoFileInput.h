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

@end
