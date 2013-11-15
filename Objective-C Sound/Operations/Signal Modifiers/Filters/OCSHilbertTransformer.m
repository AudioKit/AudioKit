//
//  OCSHilbertTransformer.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/30/12.
//  Modified by Aurelius Prochazka on 12/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's hilbert:
//  http://www.csounds.com/manual/html/hilbert.html
//

#import "OCSHilbertTransformer.h"

@interface OCSHilbertTransformer () {
    OCSAudio *asig;
}
@end

@implementation OCSHilbertTransformer

- (instancetype)initWithAudioSource:(OCSAudio *)audioSource
{
    self = [super initWithString:[self operationName]];
    if (self) {
        asig = audioSource;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ hilbert %@",
            self, asig];
}
- (OCSAudio *)realPart {
    return self.leftOutput;
}
- (OCSAudio *)imaginaryPart {
    return self.rightOutput;
}
- (OCSAudio *)sineOutput {
    return self.leftOutput;
}
- (OCSAudio *)cosineOutput{
    return self.rightOutput;
}

@end