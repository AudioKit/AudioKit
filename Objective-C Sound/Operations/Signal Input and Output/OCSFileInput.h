//
//  OCSFileInput.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoAudio.h"
#import "OCSParameter+Operation.h"

/** Reads stereo audio data from a file.
 */

@interface OCSFileInput : OCSStereoAudio

/// Create a file input.
/// @param fileName Location of the file on disk.
- (id)initWithFilename:(NSString *)fileName;

@end
