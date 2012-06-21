//
//  CSDExponentialCurvesTable.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDExponentialCurvesTable.h"

@implementation CSDExponentialCurvesTable

-(id) initWithTableSize:(int) tableSize ValueLengthPairs:(CSDParamArray *)valuesAndLengths
{
    return [self initWithTableSize:tableSize GenRoutine:kGenRoutineExponentialCurves Parameters:[valuesAndLengths parameterString]];
}

@end
