//
//  OCSFunctionTable.m
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFunctionTable.h"
#import "OCSParamConstant.h"

@interface OCSFunctionTable () {
    int size;
    FunctionTableType gen;
    NSString *parameters;    
}
@end

@implementation OCSFunctionTable
@synthesize output;

- (id)initWithType:(FunctionTableType)functionTableType
              size:(int)tableSizeOrZero 
        parameters:(NSString *)parametersAsString
{
    self = [super init];
    if (self) {
        output = [OCSParamConstant paramWithString:[self functionName]];
        size = tableSizeOrZero;
        gen = functionTableType;
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

/// Gives the CSD string for the output parameter.  
- (NSString *)description {
    return [output parameterString];
}

- (id) length;
{
    OCSParamConstant * new = [[OCSParamConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftlen(%@)", output]];
    return new;
}



@end
