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
    OCSParamArray *params;    
}
@end

@implementation OCSFunctionTable
@synthesize output;

- (id)initWithType:(FunctionTableType)functionTableType
              size:(int)tableSize
        parameters:(OCSParamArray *)parameters;
{
    self = [super init];
    if (self) {
        output = [OCSParamConstant paramWithString:[self functionName]];
        size = tableSize;
        gen = functionTableType;
        params = parameters;
    }
    return self;
}

- (id)initWithType:(FunctionTableType)functionTableType
        parameters:(OCSParamArray *)parameters;
{
    return [self initWithType:functionTableType size:0 parameters:parameters];
}

- (NSString *)functionName {
    NSString *functionName = [NSString stringWithFormat:@"%@", [self class]];
    functionName = [functionName stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return functionName;
}


//ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD {
    NSString *text;
    if (params == nil) {
        text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i",
                output, size, gen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i, %@",
                output, size, gen, [params parameterString]];
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
