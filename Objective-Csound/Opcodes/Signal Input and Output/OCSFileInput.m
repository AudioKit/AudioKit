//
//  OCSFileInput.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFileInput.h"

@interface OCSFileInput () {
    OCSParameter *outputLeft;
    OCSParameter *outputRight;
    NSString *file;
}
@end

@implementation OCSFileInput

@synthesize outputLeft;
@synthesize outputRight;

- (id)initWithFilename:(NSString *)fileName;
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParameter parameterWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        file = fileName;
    }
    return self; 
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ diskin2 \"%@\", 1, 0, 1",
            outputLeft, outputRight, file];
}


@end
