//
//  OCSExponentialCurvesTable.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSExponentialCurvesTable.h"

@implementation OCSExponentialCurvesTable

-(id) initWithSize:(int)tableSize 
  ValueLengthPairs:(OCSParamArray *)valuesAndLengths
{
    return [self initWithSize:tableSize 
                   GenRoutine:kGenRoutineExponentialCurves 
                   Parameters:[valuesAndLengths parameterString]];
}

@end
