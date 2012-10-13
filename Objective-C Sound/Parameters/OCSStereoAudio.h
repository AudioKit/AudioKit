//
//  OCSStereoAudio.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"

@interface OCSStereoAudio : NSObject

/// The output to the left channel.
@property (nonatomic, strong) OCSAudio *leftOutput;
/// The output to the right channel.
@property (nonatomic, strong) OCSAudio *rightOutput;

- (id)initWithLeftInput:(OCSAudio *)leftInput
             rightInput:(OCSAudio *)rightInput;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void) resetID;

@end
