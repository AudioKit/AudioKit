//
//  CSDExponentialCurvesTable.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"

@interface CSDExponentialCurvesTable : CSDFunctionTable
-(id) initWithTableSize:(int)tableSize ValueLengthPairs:(CSDParamArray *)partials;

@end
