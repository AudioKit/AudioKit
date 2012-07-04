//
//  OCSFileInput.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** Reads stereo audio data from a file.
 
 AOP Not complete.
 
 http://www.csounds.com/manual/html/diskin2.html
 */

@interface OCSFileInput : OCSOpcode

/// The output to the left channel.
@property (nonatomic, strong) OCSParameter *outputLeft;
/// The output to the right channel.
@property (nonatomic, strong) OCSParameter *outputRight;

- (id)initWithFilename:(NSString *)fileName;

@end
