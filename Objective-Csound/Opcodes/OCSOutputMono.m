//
//  OCSOutputMono.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOutputMono.h"

@implementation OCSOutputMono

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:@"out %@\n", input];
}

- (id)initWithInput:(OCSParam *) i {
    self = [super init];
    if (self) {
        input = i;
    }
    return self; 
}



@end
