//
//  OCSRandom.m
//  OCS iPad Examples
//
//  Created by Adam Boulanger on 9/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSRandom.h"

@interface OCSRandom()
{
    OCSParameter *minimum;
    OCSParameter *maximum;

    OCSConstant *constant;
    OCSControl *control;
    OCSParameter *audio;
    OCSParameter *output;

}
@end

@implementation OCSRandom
@synthesize constant;
@synthesize control;
@synthesize audio;
@synthesize output;

-(id)initWithMinimumValue:(OCSParameter *)minimumRange
             maximumValue:(OCSParameter *)maximumRange
{
    if( self = [super init]) {
        constant = [OCSConstant parameterWithString:[self operationName]];
        control = [OCSControl parameterWithString:[self operationName]];
        audio = [OCSParameter parameterWithString:[self operationName]];
        output = audio;
        
        minimum = minimumRange;
        maximum = maximumRange;
    }
    return self;
}

- (void)setControl:(OCSControl *)p {
    control = p;
    output = control;
}

- (void)setConstant:(OCSConstant *)p
{
    constant = p;
    output = constant;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ random %@, %@",
            output, minimum, maximum];
}

- (NSString *)description {
    return [output parameterString];
}

@end
