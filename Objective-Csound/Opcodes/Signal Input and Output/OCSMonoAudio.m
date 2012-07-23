//
//  OCSMonoAudio.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMonoAudio.h"

@interface OCSMonoAudio (){
    OCSParameter *input;
}
@end

@implementation OCSMonoAudio

- (id)initWithInput:(OCSParameter *) monoSignal {
    self = [super init];
    if (self) {
        input = monoSignal;
    }
    return self; 
}

/// Csound Prototype
- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"out %@", input];
}

@end
