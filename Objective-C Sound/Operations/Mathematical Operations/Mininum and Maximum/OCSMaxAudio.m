//
//  OCSMaxAudio.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's max:
//  http://www.csounds.com/manual/html/max.html
//

#import "OCSMaxAudio.h"

@interface OCSMaxAudio () {
    OCSArray *ains;
}
@end

@implementation OCSMaxAudio

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
            @"%@ max %@",
            self, ains];
}

@end