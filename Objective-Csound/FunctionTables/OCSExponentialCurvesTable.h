//
//  OCSExponentialCurvesTable.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFunctionTable.h"

@interface OCSExponentialCurvesTable : OCSFunctionTable

-(id) initWithSize:(int)tableSize 
  ValueLengthPairs:(OCSParamArray *)partials;

@end
