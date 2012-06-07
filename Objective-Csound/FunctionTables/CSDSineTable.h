//
//  CSDSineTable.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"
#import "CSDConstants.h" // For the GEN routine constants
#import "CSDParamArray.h"
@interface CSDSineTable : CSDFunctionTable
-(id) initWithOutput:(NSString *)output TableSize:(int) tableSize PartialStrengths:(CSDParamArray *)partials;
-(id) initDefaultsWithOutput:(NSString *)output;
@end
