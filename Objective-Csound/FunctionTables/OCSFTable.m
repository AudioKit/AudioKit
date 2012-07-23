//
//  OCSFTable.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFTable.h"
#import "OCSConstant.h"

@interface OCSFTable () {
    int isize;
    FTableType igen;
    OCSParameterArray *iargs; 
    BOOL isNormalized;
}
@end

@implementation OCSFTable
@synthesize output;
@synthesize isNormalized;

- (id)initWithType:(FTableType)fTableType
              size:(int)tableSize
        parameters:(OCSParameterArray *)parameters;
{
    self = [super init];
    if (self) {
        output = [OCSConstant globalParameterWithString:[self functionName]];
        isize = tableSize;
        igen = fTableType;
        iargs = parameters;
        isNormalized = NO;
    }
    return self;
}

- (id)initWithType:(FTableType)fTableType
        parameters:(OCSParameterArray *)parameters;
{
    return [self initWithType:fTableType size:0 parameters:parameters];
}

- (NSString *)functionName {
    NSString *functionName = [NSString stringWithFormat:@"%@", [self class]];
    functionName = [functionName stringByReplacingOccurrencesOfString:@"OCS" withString:@""];
    return functionName;
}


// Csound Prototype: ifno ftgentmp ip1, ip2dummy, isize, igen, iarga, iargb, ...
- (NSString *)stringForCSD {
    if (isNormalized) {
        igen = abs(igen); 
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (iargs == nil) {
        text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i",
                output, isize, igen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgentmp 0, 0, %i, %i, %@",
                output, isize, igen, [iargs parameterString]];
    }
    return text;
}

- (NSString *)fTableStringForCSD {
    if (isNormalized) {
        igen = abs(igen); 
    } else {
        igen = -abs(igen);
    }
    NSString *text;
    if (iargs == nil) {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i",
                output, isize, igen];
    } else {
        text = [NSString stringWithFormat:@"%@ ftgen 0, 0, %i, %i, %@",
                output, isize, igen, [iargs parameterString]];
    }
    return text;
}

- (NSString *)description {
    return [output parameterString];
}

- (OCSConstant *)length;
{
    OCSConstant * new = [[OCSConstant alloc] init];
    [new setParameterString:[NSString stringWithFormat:@"ftlen(%@)", output]];
    return new;
}



@end
