//
//  CSDFunctionTable.m
//
//  Created by Aurelius Prochazka on 4/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"

@implementation CSDFunctionTable
@synthesize output;
@synthesize integerIdentifier;
@synthesize loadTime;
@synthesize tableSize;
@synthesize generatingRoutine;
@synthesize parameters;
@synthesize text;

static int currentID = 1;

-(id)initWithTableSize:(int)size GenRoutine:(int)gen Parameters:(NSString *)params
{
    self = [super init];
    if (self) {
        _myID = currentID++;
        output = [CSDParamConstant paramWithString:[NSString stringWithFormat:@"%@%i", [self class], _myID]];
        tableSize = size;
        generatingRoutine = gen;
        parameters = params;
        
        //iSine ftgentmp 0, 0, 4096, 10, 1
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



-(NSString *) description {
    return [output parameterString];
}


@end
