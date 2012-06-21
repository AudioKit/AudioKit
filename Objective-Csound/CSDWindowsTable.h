//
//  CSDWindowsTable.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDFunctionTable.h"
#import "CSDConstants.h"

@interface CSDWindowsTable : CSDFunctionTable
-(id) initWithTableSize:(int)tableSize WindowType:(WindowTypes)window MaxValue:(int)max;
-(id) initWithTableSize:(int)size WindowType:(WindowTypes)window;

@end
