//
//  OCSFunctionTable.m
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFunctionTable.h"

@interface OCSFunctionTable () {
    int size;
    GenRoutineType gen;
    NSString *parameters;    
}
@end

@implementation OCSFunctionTable
@synthesize output;

- (id)initWithSize:(int)tableSizeOrZero 
       GenRoutine:(GenRoutineType)generatingRoutineType 
       Parameters:(NSString *)parametersAsString
{
    self = [super init];
    if (self) {
        output = [OCSParamConstant paramWithString:[self functionName]];
        size = tableSizeOrZero;
        gen = generatingRoutineType;
        parameters = parametersAsString;
    }
    return self;
}

- (NSString *)functionName {
    NSString *functionName = [NSString stringWithFormat:@"%@", [self class]];
    functionName = [functionName stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return functionName;
}


//ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD {
    NSString *text;
    if (parameters == nil) {
        text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i\n",
                output, size, gen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i, %@\n",
                output, size, gen, parameters];
    }
    return text;
}


- (NSString *)description {
    return [output parameterString];
}



@end
