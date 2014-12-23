//
//  AKMaxAudio.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's max:
//  http://www.csounds.com/manual/html/max.html
//

#import "AKMaxAudio.h"

@implementation AKMaxAudio
{
    AKArray *ains;
}

- (instancetype)initWithAudioSources:(AKArray *)inputAudioSources;
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