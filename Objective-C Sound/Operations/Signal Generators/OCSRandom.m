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
    OCSConstant *constant;
    OCSControl *control;
    OCSParameter *audio;
    OCSParameter *output;
    
    OCSParameter *min;
    OCSParameter *max;

}
@end

@implementation OCSRandom
@synthesize constant;
@synthesize control;
@synthesize audio;
@synthesize output;

-(id)initWithMinimum:(OCSControl *)minimum
             maximum:(OCSControl *)maximum
{
    if( self = [super init]) {
        constant = [OCSConstant parameterWithString:[self operationName]];
        control = [OCSControl parameterWithString:[self operationName]];
        audio = [OCSParameter parameterWithString:[self operationName]];
        output = audio;
        
        min = minimum;
        max = maximum;
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
            @"%@ random %@, %@", output, min, max];
}

- (NSString *)description {
    return [output parameterString];
}

@end
