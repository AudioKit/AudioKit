//
//  OCSFunctionTable.m
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFunctionTable.h"

@implementation OCSFunctionTable
@synthesize output;
@synthesize integerIdentifier;
@synthesize loadTime;
@synthesize tableSize;
@synthesize generatingRoutine;
@synthesize parameters;
@synthesize text;

-(id)initWithSize:(int)size 
       GenRoutine:(GenRoutineType)gen 
       Parameters:(NSString *)params
{
    self = [super init];
    if (self) {
        output = [OCSParamConstant paramWithString:[self uniqueName]];
        
        tableSize = size;
        generatingRoutine = gen;
        parameters = params;
        
        //ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
        if (parameters == nil) {
            text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i\n",
                    output, tableSize, generatingRoutine];
        } else {
            text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i, %@\n",
                    output, tableSize, generatingRoutine, parameters];
        }
    }
    return self;
}

-(NSString *) uniqueName {
    NSString * basename = [NSString stringWithFormat:@"%@", [self class]];
    basename = [basename stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return basename;
}



-(NSString *) description {
    return [output parameterString];
}


@end
