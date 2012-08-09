//
//  OCSAudioInput.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Reads audio data from an external device or stream. 
 Currently only supports mono input.
 */

@interface OCSAudioInput : OCSOpcode

/// @name Properties

/// The output is simply the signal being inputted.
@property (nonatomic, strong) OCSParameter *output;

@end
