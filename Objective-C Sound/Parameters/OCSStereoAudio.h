//
//  OCSStereoAudio.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter.h"

@interface OCSStereoAudio : NSObject

/// The output to the left channel.
@property (nonatomic, strong) OCSParameter *leftOutput;
/// The output to the right channel.
@property (nonatomic, strong) OCSParameter *rightOutput;

/// Allows the unique identifying integer to be reset so that the numbers don't increment indefinitely.
+ (void) resetID;

@end
