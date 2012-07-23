//
//  OCSFSignalFromMonoAudio.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"
#import "OCSFSignal.h"

/** Generate an f-Signal from a mono audio source using phase vocoder overlap-add synthesis.
 
 TODO: Make each of the inputs a property.
 TODO: Add support for format and init optional variables.
 */

typedef enum
{
    kHammingWindow=0,
    kVonHannWindow=1,

} WindowType;

@interface OCSFSignalFromMonoAudio : OCSOpcode

// The output is a f-Signal.
@property (nonatomic, strong) OCSFSignal *output;

- (id)initWithInput:(OCSParameter *)monoInput
            fftSize:(OCSConstant *)fftSize
            overlap:(OCSConstant *)overlap
         windowType:(WindowType)windowType
   windowFilterSize:(OCSConstant *)windowSize;

@end
