//
//  OCSOutputMono.m
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOutputMono.h"

@interface OCSOutputMono (){
    OCSParam *input;
}
@end

@implementation OCSOutputMono

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
