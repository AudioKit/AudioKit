//
//  OCSFileInput.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Reads stereo audio data from a file.
 */

@interface OCSFileInput : OCSAudio

/// @name Properties

/// The output to the left channel.
@property (nonatomic, strong) OCSAudio *leftOutput;
/// The output to the right channel.
@property (nonatomic, strong) OCSAudio *rightOutput;


/// @name Initialization

/// Create a file input.
/// @param fileName Location of the file on disk.
- (id)initWithFilename:(NSString *)fileName;

@end
