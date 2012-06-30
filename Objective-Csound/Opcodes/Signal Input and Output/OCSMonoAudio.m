//
//  OCSMonoAudio.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSMonoAudio.h"

@interface OCSMonoAudio (){
    OCSParam *input;
}
@end

@implementation OCSMonoAudio

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"out %@\n", input];
}

- (id)initWithInput:(OCSParam *) monoSignal {
    self = [super init];
    if (self) {
        input = monoSignal;
    }
    return self; 
}



@end
