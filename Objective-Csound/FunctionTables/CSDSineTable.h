//
//  CSDSineTable.h
//
//  Created by Aurelius Prochazka on 6/6/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"

@interface CSDSineTable : CSDFunctionTable
-(id) initWithTableSize:(int) tableSize PartialStrengths:(CSDParamArray *)partials;
-(id) init;
@end
