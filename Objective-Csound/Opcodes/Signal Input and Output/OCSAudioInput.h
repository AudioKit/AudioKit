//
//  OCSAudioInput.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSAudioInput : OCSOpcode

@property (nonatomic, strong) OCSParameter *output;

@end
