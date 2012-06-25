//
//  OCSOscillator.h
//
//  Created by Aurelius Prochazka on 4/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** A simple oscillator with linear interpolation.

@warning *Not a complete reproduction of all of Csound's oscili opcode*
 */
@interface OCSOscillator : OCSOpcode 

@property (nonatomic, strong) OCSParam *audio;
@property (nonatomic, strong) OCSParamControl *control;
@property (nonatomic, strong) OCSParam *output;

- (id)initWithAmplitude:(OCSParam *) amp 
              Frequency:(OCSParam *) freq
          FunctionTable:(OCSFunctionTable *) f;

@end
