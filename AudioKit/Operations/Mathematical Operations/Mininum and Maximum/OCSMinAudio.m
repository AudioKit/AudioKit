//
//  OCSMinAudio.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's min:
//  http://www.csounds.com/manual/html/min.html
//

#import "OCSMinAudio.h"

@interface OCSMinAudio () {
    OCSArray *ains;
}
@end

@implementation OCSMinAudio

- (instancetype)initWithAudioSources:(OCSArray *)inputAudioSources;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        ains = inputAudioSources;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ min %@",
            self, ains];
}

@end