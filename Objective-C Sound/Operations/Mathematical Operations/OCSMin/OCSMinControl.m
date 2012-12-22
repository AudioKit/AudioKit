//
//  OCSMinControl.m
//  Objective-C Sound
//
//  Auto-generated from database on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's min:
//  http://www.csounds.com/manual/html/min.html
//

#import "OCSMinControl.h"

@interface OCSMinControl () {
    OCSArray *kins;
}
@end

@implementation OCSMinControl

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
            @"%@ min %@",
            self, kins];
}

@end