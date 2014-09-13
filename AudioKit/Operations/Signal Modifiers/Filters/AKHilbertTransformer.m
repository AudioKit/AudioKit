//
//  AKHilbertTransformer.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/30/12.
//  Modified by Aurelius Prochazka on 12/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's hilbert:
//  http://www.csounds.com/manual/html/hilbert.html
//

#import "AKHilbertTransformer.h"

@implementation AKHilbertTransformer
{
    AKAudio *asig;
}

- (instancetype)initWithAudioSource:(AKAudio *)audioSource
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
- (AKAudio *)realPart {
    return self.leftOutput;
}
- (AKAudio *)imaginaryPart {
    return self.rightOutput;
}
- (AKAudio *)sineOutput {
    return self.leftOutput;
}
- (AKAudio *)cosineOutput{
    return self.rightOutput;
}

@end