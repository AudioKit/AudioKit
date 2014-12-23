//
//  AKMinControl.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's min:
//  http://www.csounds.com/manual/html/min.html
//

#import "AKMinControl.h"

@implementation AKMinControl
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
            @"%@ min %@",
            self, kins];
}

@end