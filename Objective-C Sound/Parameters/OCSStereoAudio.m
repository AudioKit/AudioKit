//
//  OCSStereoAudio.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSStereoAudio.h"

@interface OCSStereoAudio () {
    OCSParameter *aOutL;
    OCSParameter *aOutR;
    int _myID;
}
@end

@implementation OCSStereoAudio

@synthesize leftOutput=aOutL;
@synthesize rightOutput=aOutR;

static int currentID = 1;

+(void) resetID {
    currentID = 1;
}

- (id)init
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        aOutL  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"aLeft%i",_myID]];
        aOutR  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"aRight%i",_myID]];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", aOutL, aOutR];
}
@end

