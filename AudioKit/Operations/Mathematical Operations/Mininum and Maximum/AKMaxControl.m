//
//  AKMaxControl.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's max:
//  http://www.csounds.com/manual/html/max.html
//

#import "AKMaxControl.h"

@implementation AKMaxControl
{
    AKArray *kins;
}

- (instancetype)initWithControls:(AKArray *)inputControls;
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