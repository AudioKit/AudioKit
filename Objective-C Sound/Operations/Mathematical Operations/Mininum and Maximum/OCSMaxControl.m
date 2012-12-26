//
//  OCSMaxControl.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's max:
//  http://www.csounds.com/manual/html/max.html
//

#import "OCSMaxControl.h"

@interface OCSMaxControl () {
    OCSArray *kins;
}
@end

@implementation OCSMaxControl

- (id)initWithControls:(OCSArray *)inputControls;
{
    self = [super initWithString:[self operationName]];
    if (self) {
        kins = inputControls;
    }
    return self;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ max %@",
            self, kins];
}

@end