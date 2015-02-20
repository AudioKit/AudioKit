//
//  AKResynthesizedAudio.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKResynthesizedAudio.h"

@implementation AKResynthesizedAudio
{
    AKFSignal *fSrc;
}


- (instancetype)initWithSignal:(AKFSignal *)source;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        fSrc = source;
        self.state = @"connectable";
        self.dependencies = @[source];
    }
    return self; 
}

// Csound Prototype: ares pvsynth fsrc
- (NSString *)stringForCSD 
{
    return [NSString stringWithFormat:@"%@ pvsynth %@", self, fSrc];
}

@end
