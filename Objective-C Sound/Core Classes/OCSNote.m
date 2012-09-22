//
//  OCSNote.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 9/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSNote.h"

@implementation OCSNote

@synthesize instrument;
@synthesize properties;

- (id)init {
    self = [super init];
    if (self) {
        properties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end
